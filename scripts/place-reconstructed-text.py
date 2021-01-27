# This script will read a font from one edition (from one API)
# And position the reconstructed text in another (or the same)
# edition based on the font metrics.

import requests, math
from shapely import wkt, affinity
from shapely.ops import unary_union
from tqdm import tqdm


def main():
    # Set the corresponding edition ids
    edition_id = 1657
    dest_edition_id = 894

    # Access details for the font information
    username = 'bronsonbdevost@gmail.com'
    password = 'lbcirva7'
    api = 'https://api.qumranica.org/v1'
    headers = login(username, password, api)
    print(f'Copying font from {api}, edition id {edition_id}. Using headers:')
    print(headers)
    print('\n')
    
    # Access details for the edition where the text will be reconstructed
    write_username = 'test@1.com'
    write_password = 'test'
    write_api = 'http://localhost:5000/v1'
    write_headers = login(write_username, write_password, write_api)
    print(f'Connecting to {write_api}, edition id {dest_edition_id}.\nUsing headers:')
    print(write_headers)

    # get font info
    idx = 0
    font_details = get_font(headers, api, edition_id, idx)
    # Copy the font to the destination
    if edition_id != dest_edition_id or write_api != api:
        print(f'Copying font to {write_api}, edition id {dest_edition_id}.')
        copy_font(write_headers, write_api, dest_edition_id, font_details)

    # gather text
    # get text fragments
    text_fragments = get_text_fragments(write_headers, write_api, dest_edition_id)

    # Place text fragments
    print(f'Laying out text for {write_api}, edition id {dest_edition_id}.')
    x_advance = font_details['avg_glyph_width'] * 60 * len(text_fragments)
    for text_fragment in tqdm(text_fragments):
        x_advance = calculate_text_rois(write_headers, write_api, dest_edition_id, text_fragment, x_advance, font_details)
        x_advance -= font_details['line_space'] * 2


def login(username: str, password: str, api: str) -> dict:
    r = requests.post(f"{api}/users/login", json={'email': username, 'password': password})
    headers = {"Authorization": "Bearer " + r.json()["token"]}
    return headers


def get_font(headers: dict, api: str, edition_id: int, idx: int) -> dict:
    r = requests.get(f'{api}/editions/{edition_id}/scribalfonts', headers=headers)
    font_list = r.json()
    kerning_pairs = {}
    glyph_dict = {}

    font = font_list['scripts'][idx]
    for kerning_pair in font['kerningPairs']:
        if kerning_pair['firstCharacter'] not in kerning_pairs:
            kerning_pairs[kerning_pair['firstCharacter']] = {}

        if kerning_pair['secondCharacter'] not in kerning_pairs[kerning_pair['firstCharacter']]:
            kerning_pairs[kerning_pair['firstCharacter']][kerning_pair['secondCharacter']] = {'x_kern': kerning_pair['xKern'], 'y_kern': kerning_pair['yKern']}

    glyph_widths = []
    for glyph in font['glyphs']:
        shape = wkt.loads(glyph['shape'])
        glyph_widths.append(shape.bounds[2] - shape.bounds[0])
        shape = affinity.translate(shape, 0, glyph['yOffset'] - (shape.bounds[3] - shape.bounds[1]))

        glyph_dict[glyph['character']] = shape

    return {
        'glyphs': glyph_dict,
        'kern': kerning_pairs,
        'line_space': font['lineSpace'],
        'word_space': font['wordSpace'],
        'avg_glyph_width': sum(glyph_widths)/len(glyph_widths)
    }


def copy_font(headers: dict, api: str, edition_id: int, font: dict):
    # Check for exiting font and create a new one if necessary
    r = requests.get(f'{api}/editions/{edition_id}/scribalfonts', headers=headers)
    resp = r.json()
    script_id = 0
    if 'scripts' in resp and len(resp['scripts']) > 0:
        script_id = resp['scripts'][0]['scribalFontId']
    else:
        create_font = {"wordSpace": font['word_space'], "lineSpace": font['line_space']}
        r = requests.post(f'{api}/editions/{edition_id}/scribalfonts', json=create_font, headers=headers)
        resp = r.json()
        script_id = resp['scribalFontId']
        
    # Copy glyphs
    for character in tqdm(font['glyphs'].keys()):
        y_off = math.floor(font['glyphs'][character].bounds[1])
        create_character = {
            "character": character,
            "shape": affinity.translate(font['glyphs'][character], 0, -y_off).wkt,
            "yOffset": y_off
        }
        requests.post(f'{api}/editions/{edition_id}/scribalfonts/{script_id}/glyphs', json=create_character, headers=headers)
        
    for firstCharacter in tqdm(font['kern'].keys()):
        for secondCharacter in font['kern'][firstCharacter]:
            kp = {
                "firstCharacter": firstCharacter,
                "secondCharacter": secondCharacter,
                "xKern": font['kern'][firstCharacter][secondCharacter]['x_kern'],
                "yKern": font['kern'][firstCharacter][secondCharacter]['y_kern']
            }
            requests.post(f'{api}/editions/{edition_id}/scribalfonts/{script_id}/kerning-pairs', json=kp,
                          headers=headers)


def get_text_fragments(headers: dict, api: str, edition_id: int) -> list:
    r = requests.get(f'{api}/editions/{edition_id}/text-fragments', headers=headers)
    frags = r.json()
    return [x['id'] for x in frags['textFragments']]


def calculate_text_rois(headers: dict, api: str, edition_id: int, text_fragment_id: int, x_advance: int, font: dict) -> int:
    r = requests.get(f'{api}/editions/{edition_id}/text-fragments/{text_fragment_id}', headers=headers)
    text = r.json()
    min_x = x_advance
    y_pos = font['line_space']
    text_chunks = []
    current_text_chunk = []
    for tf in text['textFragments']:
        last_reconstructed = False
        for line in tf['lines']:
            last_char = ''
            line_shape = wkt.loads('POINT(0 0)')
            x_pos = x_advance
            for sign in line['signs']:
                for si in sign['signInterpretations']:
                    if si['character'] in font['glyphs']:
                        glyph = font['glyphs'][si['character']]
                        kern = 0
                        if last_char != '' and last_char in font['kern'] and si['character'] in font['kern'][last_char]:
                            kern = font['kern'][last_char][si['character']]['x_kern']

                        shape = affinity.translate(glyph, x_pos - glyph.bounds[2] - 10 - kern, y_pos)
                        line_shape = line_shape.union(shape)

                        x_pos = x_pos - glyph.bounds[2] - 10 - kern
                        last_char = si['character']
                        if 20 in [x['attributeValueId'] for x in si['attributes']]:
                            if last_reconstructed:
                                current_text_chunk.append({'sid': si['signInterpretationId'], 'shape': shape})
                            else:
                                text_chunks.append(current_text_chunk)
                                current_text_chunk = []
                            last_reconstructed = True
                        else:
                            last_reconstructed = False

                    if si['character'] == '' and 'SPACE' in [x['attributeValueString'] for x in si['attributes']]:
                        x_pos -= font['word_space']
                        last_char = ''

                    if x_pos < min_x:
                        min_x = x_pos

            y_pos += font['line_space']

        for text_chunk in text_chunks:
            # Write reconstructed text chunk to the destination api
            if len(text_chunk) > 0:
                write_reconstructed_text(text_chunk, api, headers, edition_id)

    return min_x


def write_reconstructed_text(text_chunk: list, api: str, headers: dict, edition_id: int):
    chunk_shape = unary_union([x['shape'] for x in text_chunk])
    virtual_artefact_shape = chunk_shape.envelope
    trans_x, trans_y = math.floor(virtual_artefact_shape.bounds[0]), math.floor(virtual_artefact_shape.bounds[1])
    shifted_virtual_artefact_shape = affinity.translate(virtual_artefact_shape, -trans_x, -trans_y)
    virtual_artefact = {
        "mask": shifted_virtual_artefact_shape.wkt,
        "placement": {
            "scale": 1,
            "rotate": 0,
            "zIndex": 0,
            "translate": {
                "x": trans_x,
                "y": trans_y
            },
            "mirrored": False
        },
        "name": "reconstructed text",
        "statusMessage": "auto-placement",
        "masterImageId": None
    }
    
    # Write virtual artefact and get its id
    r = requests.post(f'{api}/editions/{edition_id}/artefacts', json=virtual_artefact, headers=headers)
    resp = r.json()
    virtual_artefact_id = resp['id']
    
    rois = []
    for roi in text_chunk:
        shape = roi['shape'].envelope
        shape = affinity.translate(shape, -trans_x, -trans_y)
        roi_trans_x, roi_trans_y = math.floor(shape.bounds[0]), math.floor(shape.bounds[1])
        shifted_shape = affinity.translate(shape, -roi_trans_x, -roi_trans_y)
        rois.append({
            "artefactId": virtual_artefact_id,
            "signInterpretationId": roi['sid'],
            "shape": shifted_shape.wkt,
            "translate": {
                "x": roi_trans_x,
                "y": roi_trans_y
            },
            "stanceRotation": 0,
            "exceptional": False,
            "valuesSet": True
        })
        
    # Batch write rois
    requests.post(f'{api}/editions/{edition_id}/rois/batch', json={'rois': rois}, headers=headers)
        
    
# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    main()
