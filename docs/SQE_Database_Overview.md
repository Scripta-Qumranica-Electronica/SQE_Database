- [Introduction](#introduction)
  - [Creating an edition in the SQE Database](#creating-an-edition-in-the-sqe-database)
    - [manuscript table](#manuscript-table)
    - [edition table](#edition-table)
    - [edition_editor table](#edition_editor-table)
  - [Detailed manuscript data input/output](#detailed-edition-data-inputoutput)
    - [edition_data table](#edition_data-table)
    - [edition\_data\_owner table](#edition_data_owner-table)
  - [Data creation/deletion and tracking](#data-creationdeletion-and-tracking)
      - [Summary](#summary)
  - [Textual data](#textual-data)
    - [sign table](#sign-table)
    - [sign_char table](#sign_char-table)
    - [sign\_char\_attribute table](#sign_char_attribute-table)
    - [attribute_value table](#attribute_value-table)
    - [attribute table](#attribute-table)
    - [position\_in\_stream table](#position_in_stream-table)
    - [linking signs to words, lines, text fragments, and editions](#linking-signs-to-words,-lines,-text-fragments,-and-editions)
  - [Image data](#image-data)
    - [SQE_image table](#sqe_image-table)
    - [image_urls table](#image_urls-table)
    - [image_catalog table](#image_catalog-table)
  - [Binding text to image](#binding-text-to-image)
  - [Sharing](#sharing-system)
  - [user/permissions system](#user-permissions-system)
      - [sessions](#sessions)

# Introduction

The SQE database is a relational database containing data pertaining to text transcriptions, related image data, and other cataloging/bibliographical information.  If you do not know what a relational database is, see [here](https://mariadb.com/kb/en/library/introduction-to-relational-databases/), or [here](https://en.wikiversity.org/wiki/Introduction_to_Relational_Databases).  This tutorial assumes you know the basics of `tables`, `columns`, and `rows` in a database and the use of `primary key`s for addressing entries and `foreign key`s for linking entries.  It is also important to understand the two main types of relationships in a relational database: `one to many` and `many to many`.  An online commented schema for the database can be accessed [here](https://qumranica.org/database).

## Creating an Edition in the SQE Database

The SQE database often makes use of abstract placeholders to link data that can can changed due to editorial decisions.  A primary example of this is the table [`manuscript`](https://qumranica.org/database/tables/manuscript.html).  This table is nothing more than a single column list of `ID`s:

### [manuscript](https://qumranica.org/database/tables/manuscript.html) table

|manuscript_id|
|:--:|
|1|
|2|
|3|
|4|
|5|

All data for a reconstructed edition is ultimately linked to a `edition_id`, which is further described in the [`edition`](https://qumranica.org/database/tables/edition.html) table.

Let's start with the basics, every edition created by an editor or group of editors (including all the initial editions created from QWB data and algorithmic/ai processes) is treated as an [`edition`](https://qumranica.org/database/tables/edition.html) of a [`manuscript`](https://qumranica.org/database/tables/manuscript.html), where each individual editor is referenced as an [`edition_editor`](https://qumranica.org/database/tables/edition_editor.html).  The [`edition`](https://qumranica.org/database/tables/edition.html) table is used to store information regarding the state of the reconstructed edition and each linked entry in the [`edition_editor`](https://qumranica.org/database/tables/edition_editor.html) table provides the information about each editor's permissions and admin status (more on that a little later in [sharing](#sharing)).

### [edition](https://qumranica.org/database/tables/edition.html) table

|edition_id|manuscript_id|locked|copyright_holder|collaborators|public
|:--:|:--:|:--:|:--:|:--:|:--:|
|1|1|1|"Reinhard G. Kratz"|null|1
|2|2|1|"Reinhard G. Kratz"|null|1
|3|2|1|"Reinhard G. Kratz"|null|0
|4|2|1|"Reinhard G. Kratz"|null|0
|5|3|1|"Reinhard G. Kratz"|null|1

Here we find 5 distinct editions, but three of them are alternate versions of the same edition (`edition_id` 3). The collaborator columns may be left `null`, in which case those entities are computed based on the edition editors
.
### [edition_editor](https://qumranica.org/database/tables/edition_editor.html) table

The actual [`edition_editor`](https://qumranica.org/database/tables/edition_editor.html)s themselves are stored in the [`edition_editor`](https://qumranica.org/database/tables/edition_editor.html) table and each have a unique `edition_editor_id`:

|edition\_editor\_id|user_id|edition\_id|may_write|may_lock|may_read|is_admin|
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
|1|1|1|0|0|1|1|
|2|2|2|1|1|1|1|
|3|3|2|1|0|1|0|
|4|4|2|0|0|1|0|
|5|1|3|0|0|1|1|

If we follow the `ID`s here we see, for instance, that the [`edition_editor`](https://qumranica.org/database/tables/edition_editor.html) associated with `edition_editor_id` 1 is `user_id` 1 (this is the default user that imported all the data from QWB and the image processing data from Tel Aviv).  The `edition_editor_id` 1 is linked to `edition_id` 1, which we see in the table above is linked to `manuscript_id` 1.  Note, however, that we see an editorial team working on `edition_id` 2, since three different `edition_editor_id`s link to the same `edition_id`.  In this case `user_id` 2 has full priveleges to work on the edition and as admin will be able to add new editors and to change the permissions of current editors.  The editor with `user_id` 3 has write and read priveleges, but may not lock the edition (that is prevent any changes to it) and is not an admin. The editor with `user_id` 4 has read only access (for more on this see [sharing](#sharing)).

This system also greatly simplifies the sharing of editions with other users in the system. Let's pretend I am `user_id` 2 and I want to create my own edition of the manuscript in `edition_id` 1.  Since I am not creating an edition of some new, previously undiscovered manuscript, but rather a new edition of an existing manuscript edition, I will simply create a new [`edition`](https://qumranica.org/database/tables/edition.html) linked to `edition_id` 1.

__New entry in [`edition`](https://qumranica.org/database/tables/edition.html)__

|edition_id|manuscript_id|locked|copyright_holder|collaborators|public
|:--:|:--:|:--:|:--:|:--:|:--:|
|6|1|0|"Scripta Qumranica Electronica"|null|1

Then I must create a new [`edition_editor`](https://qumranica.org/database/tables/edition_editor.html) for my `user_id` and give myself admin status and full permissions.

__New entry in [`edition_editor`](https://qumranica.org/database/tables/edition_editor.html)__

|edition\_editor\_id|user_id|edition\_id|may_write|may_lock|may_read|is_admin|
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
|6|2|6|1|1|1|1|

Now we know in the database that [`edition_id`](https://qumranica.org/database/tables/edition.html) 6 and [`edition_id`](https://qumranica.org/database/tables/edition.html) 1 are different version of the same manuscript, since they both link to that abstract `manuscript_id` 1 via an entry in the [`edition`](https://qumranica.org/database/tables/edition.html) table.  Since the system registers my newly created edition as and alternate of `manuscript_id` 1 and it will show up in searches alongside any other accessible editions of that manuscript.

Let's go just a bit further and try sharing a edition.  My colleague, who has `user_id` 3, wants to jointly edit this new edition, so we create a new entry in [`edition_editor`](https://qumranica.org/database/tables/edition_editor.html) and we will choose to let her write, but we won't let her lock it or act as admin.

__New entry in [`edition_editor`](https://qumranica.org/database/tables/edition_editor.html)__

|edition\_editor\_id|user_id|edition\_id|may_write|may_lock|may_read|is_admin|
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
|7|3|6|1|0|1|0|

Now any changes she makes will be attributed to her via [`edition_editor`](https://qumranica.org/database/tables/edition_editor.html) id 7, and any changes I make will be attributed to me via [`edition_editor`](https://qumranica.org/database/tables/edition_editor.html) id 6.  We always know who made what edits and we have a complete edition, since both [`edition_editor`](https://qumranica.org/database/tables/edition_editor.html)s share a common `edition_id` and thus the data of each [`edition_editor`](https://qumranica.org/database/tables/edition_editor.html) complement each other.  These two [`edition_editor`](https://qumranica.org/database/tables/edition_editor.html)s will be dependent upon each other to create a complete edition, and if you copied data belonging to just one or just the other, you would end up with an incomplete and likely non-functional edition (more on that later in [sharing](#sharing)).

## Detailed edition data input/output

So far we have only looked at creating these abstract manuscripts, editions, and edition editors.  Now we want to access information in the edition and even insert or change data.  All data pertaining to a digital edition is linked to an `edition_id` and an `edition_editor_id` through an "owner" table.  These "owner" tables create many-to-many relationship between an [`edition`](https://qumranica.org/database/tables/edition.html), [`edition_editor`](https://qumranica.org/database/tables/edition_editor.html), and the tables with data for the edition.

Let's start with the name of the manuscript in our edition.  Among other things the *x*`_owner` tables generally contain human readable names.  So for manuscript metadata we have the following:

### [manuscript_data](https://qumranica.org/database/tables/edition_data.html) table

|manuscript\_data\_id|manuscript_id|name|
|:--:|:--:|:--:|
|1|1|1QS|
|2|2|1QSa|
|3|3|1QSb|
|4|4|1QpHab|
|5|5|1QM|

We see here that one name for `manuscript_id` 1 is "1QS", but how do we know that is the name associated with edition id 1?  Since the name of this table is [`manuscript_data`](https://qumranica.org/database/tables/edition_data.html), we look that information up in the [`manuscript_data_owner`](https://qumranica.org/database/tables/edition_data_owner.html) table.

### [manuscript\_data\_owner](https://qumranica.org/database/tables/edition_data_owner.html) table

|manuscript\_data\_id|edition\_editor\_id|edition\_id|
|:--:|:--:|:--:|
|1|1|1|
|2|2|2|
|3|3|3|
|4|4|4|
|5|5|5|

This table tells us that the linked entry in the [`manuscript_data`](https://qumranica.org/database/tables/edition_data.html) table for `edition_id` 1 and `edition_editor_id` 1 is `manuscript_data_id` 1.

## Data creation/deletion and tracking

Now, remember that I created my own copy of `edition_id` 1 for `user_id` 2, and it has an `edition_id` of 6 and an `edition_editor_id` of 6.  If I want to give my edition of this manuscript a different name, I do so by creating two entries (this is done automatically by the SQE\_API):

__New entry in [`manuscript_data`](https://qumranica.org/database/tables/edition_data.html)__

|manuscript\_data\_id|manuscript_id|name|
|:--:|:--:|:--:|
|6|1|1QSerekh|

__New entry in [`edition_data_owner`](https://qumranica.org/database/tables/edition_data_owner.html)__

|manuscript\_data\_id|edition\_editor\_id|edition\_id|
|:--:|:--:|:--:|
|6|6|6|

My colleague (`user_id` 3 with `edition_id` 7 and `edition_editor_id` 7), who has her own edition of this manuscript may decide to change the name too:

__New entry in [`edition_data`](https://qumranica.org/database/tables/edition_data.html)__

|manuscript\_data\_id|manuscript_id|name|
|:--:|:--:|:--:|
|7|1|Serekh ha-Yachad|

__New entry in [`manuscript_data_owner`](https://qumranica.org/database/tables/edition_data_owner.html)__

|manuscript\_data\_id|edition\_editor\_id|edition\_id|
|:--:|:--:|:--:|
|7|7|7|

Finally, I may decide I like her name better and I can update my version (`edition_id` 6 and `edition_editor_id` 6) accordingly:

__New entry in [`manuscript_data_owner`](https://qumranica.org/database/tables/edition_data_owner.html)__

|manuscript\_data\_id|edition\_editor\_id|edition\_id|
|:--:|:--:|:--:|
|7|6|6|

Notice, I did not need to create a new entry in the [`manuscript_data`](https://qumranica.org/database/tables/edition_data.html) table, I actually take my colleague's entry (`manuscript_data_id` 7) and link it to my edition and edition editor in the [`manuscript_data_owner`](https://qumranica.org/database/tables/edition_data_owner.html) table.  I must also delete the old link (`manuscript_data_id` 6, `edition_editor_id` 6, and `edition_id` 6) from the [`manuscript_data_owner`](https://qumranica.org/database/tables/edition_data_owner.html) table.  The entry for `manuscript_data_id` 6 in the [`manuscript_data`](https://qumranica.org/database/tables/edition_data.html) table is now essentially "orphaned" in the database, but it may be linked again in the future to some other `edition_editor_id`, who knows?

So the database tables now look like:

|manuscript\_data\_id|manuscript_id|name|
|:--:|:--:|:--:|
|1|1|1QS|
|2|2|1QSa|
|3|3|1QSb|
|4|4|1QpHab|
|5|5|1QM|
|6|1|1QSerekh|
|7|1|Serekh ha-Yachad|

|manuscript\_data\_id|edition\_editor\_id|edition\_id|
|:--:|:--:|:--:|
|1|1|1|
|2|2|2|
|3|3|3|
|4|4|4|
|5|5|5|
|7|7|7|
|7|6|6|

#### Summary

Whenever you ask the SQE\_API to insert new data or to change data, it always checks to see if an entry already exists with that information.  If an entry already exists, then it links your edition to the preexisting data as in the example above.  Also, no entry is changed, instead it is copied to a new entry with the requested alterations, the binding of the old entry to the `edition_id` and `edition_editor_id` in the *x*`_owner` table is deleted, and a new entry is made in the *x*`_owner` table binding the id of the newly created entry to your `edition_id` and `edition_editor_id`.

In addition to that, no data entries are ever deleted from the database, rather they are simply unlinked from the current `edition_id` and `edition_editor_id` by removing the entry in the *x*`_owner` table.  In essence each `edition_id` and `edition_editor_id` subscribes or unsubscribes to data via these *x*`_owner` tables.

Whenever a user inserts data in the database, makes an update, or deletes something, each individual transaction is recorded in the [`main_action`](https://qumranica.org/database/tables/main_action.html) and [`single_action`](https://qumranica.org/database/tables/single_action.html) tables.  These tables make it possible to find the editor who originally created each particular data entry in the database, and in this way we can build up a full attribution history for every aspect of any [`edition`](https://qumranica.org/database/tables/edition.html) in the database no matter how information may have been shared or reused.

The system of linking and unlinking is perhaps most easily understood by the concept of copying, or better, cloning an edition.  When the SQE\_API clones a edition, it creates a new [`edition`](https://qumranica.org/database/tables/edition.html) entry and corresponding [`edition_editor`](https://qumranica.org/database/tables/edition_editor.html) entry associated with the `user_id` of the person requesting the clone.  Then it simply searches for every entry in the "owner" tables that has an `edition_id` matching the edition to be cloned and creates a new corresponding entry for each of those, but pointing instead to the newly created, or cloned, `edition_id` and `edition_editor_id`.  Cloning an edition does not create any new data, it just creates a set of links to data via the many *x*`_owner` tables.

## Textual data

Transcribed text is organized within the database as a directed acyclic graph, or "sign stream", which is stored concretely in the [`position_in_stream`](https://qumranica.org/database/tables/position_in_stream.html) table.  It is perhaps a bit inexact to say the [`position_in_stream`](https://qumranica.org/database/tables/position_in_stream.html) organizes the transcribed text, rather it organizes abstract signs.  The [`sign`](https://qumranica.org/database/tables/sign.html) table is similar to the [`manuscript`](https://qumranica.org/database/tables/manuscript.html) table in that it is simply a list of abstract `sign_id`s with no actual data of its own.

### [sign](https://qumranica.org/database/tables/sign.html) table

|sign_id|
|:--:|
|1|
|2|
|3|
|4|
|5|
|6|
|7|


These signs could be conceivably be linked to anything, so they get linked to a [`sign_interpretation`](https://qumranica.org/database/tables/sign_interpretation.html) table, which provides an open ended system for describing the sign. The most common interpretations of a sign are as a letter, so that is defined directly within the [`sign_interpretation`](https://qumranica.org/database/tables/sign_interpretation.html) table. The [`sign`](https://qumranica.org/database/tables/sign.html)s also are linked to [`line`](https://qumranica.org/database/tables/line.html)s and to each other in the [`position_in_stream`](https://qumranica.org/database/tables/position_in_stream.html) table.  The interpretations of these abstract [`sign`](https://qumranica.org/database/tables/sign.html)s begins in the [`sign_interpretation`](https://qumranica.org/database/tables/sign_interpretation.html) table:

### [sign_interpretation](https://qumranica.org/database/tables/sign_interpretation.html) table

|sign\_interpretation\_id|sign_id|is_variant|character|
|:--:|:--:|:--:|:--:|
|1|1|0||
|2|2|0|ל|
|3|3|0||
|4|4|0||
|5|5|0|ש|
|6|6|0|י|
|7|7|0|ם|

As you can see, we find some entries with Hebrew letters (`sign_char_id`s 2, 5–7), but there are also entries without any letter.  These entries are not associated with any letter, but link to non-letter information via the [`sign_interpretation_attribute`](https://qumranica.org/database/tables/sign_interpretation_attribute.html) table:

### [sign\_interpretation\_attribute](https://qumranica.org/database/tables/sign_interpretation_attribute.html) table

|sign\_interpretation\_attribute\_id|sign\_interpretation\_id|attribute\_value\_id|sequence|numeric_value|
|:--:|:--:|:--:|:--:|:--:|
|1|1|10|0|null|
|131071|1|12|0|null|
|163837|1|14|0|null|
|1792961|1|9|0|null|
|167931|2|1|0|null|
|1738506|3|5|0|null|
|1937378|3|16|0|null|
|3772357|3|20|0|null|
|1407451|4|2|0|null|
|3772358|4|20|0|null|
|167932|5|1|0|null|
|167933|6|1|0|null|
|167934|7|1|0|null|

From this table, we can see that while `sign_id` 1 had no letter associated with it in the [`sign_interpretation`](https://qumranica.org/database/tables/sign_interpretation.html) table entry with `sign_interpretation_id` 1, it actually has four attributes associated with it (`attribute_value_id`s 10, 12, 14, and 9) via the [`sign_interpretation_attribute`](https://qumranica.org/database/tables/sign_interpretation_attribute.html) table.  You will find descriptions of these attributes in the [`attribute_value`](https://qumranica.org/database/tables/attribute_value.html) table:

### [attribute_value](https://qumranica.org/database/tables/attribute_value.html) table

|attribute\_value\_id|attribute_id|string_value|description|
|:--:|:--:|:--:|:--:|
|1|1|LETTER||
|2|1|SPACE||
|3|1|POSSIBLE_VACAT||
|4|1|VACAT||
|5|1|DAMAGE||
|6|1|BLANK LINE||
|7|1|PARAGRAPH_MARKER||
|8|1|LACUNA||
|9|1|BREAK||
|10|2|LINE_START||
|11|2|LINE_END||
|12|2|TEXT_FRAGMENT_START||
|13|2|TEXT_FRAGMENT_END||
|14|2|MANUSCRIPT_START||

Now we see that `sign_id` 1 is linked to `sign_interpretation_id` 1, and that it gets the attributes of MANUSCRIPT_START, TEXT_FRAGMENT_START, LINE_START, and BREAK, and we see that it marks the first line of the first text fragment of a manuscript, and that the actual beginning of this manuscript is now broken.  So we are actually lacking the initial text for this manuscript.

If we go one step further, we see that the [`attribute`](https://qumranica.org/database/tables/attribute.html) table provides us with the category of each [`artefact_value`](https://qumranica.org/database/tables/artefact_value.html)

### [attribute](https://qumranica.org/database/tables/attribute.html) table

|attribute\_id|name|type|description|
|:--:|:--:|:--:|:--:|
|1|sign_type|STRING|Type of char|
|2|break_type|STRING|Defines a metasign marking a disruption in the text, probably do to physical manuscript damage|
|6|is_reconstructed|BOOL|true if the letter is totally reconstructed (brackets are not part of the sign stream!)|

So, we can now find letters in the database, we can also find "control" type characters marking the beginnings and ends of manuscripts/text fragments/lines, etc.  These attributes can also convey information about letters, such as if they are reconstructed (`attribute_id` 6, `attribute_value_id` 20) or damaged and thus uncertain (`attribute_id` 5, `attribute_value_id` 19).  Users can even add their own custom attributes to apply to signs; the attributes need not have anything to do with text and could, for instance, mark wormholes, dry-lines, modern markings, or anything imaginable.

But, how does such a "bag of signs" get organized into readable text, and assigned to words/lines/text fragments/manuscripts?  The [`sign`](https://qumranica.org/database/tables/sign.html) table and the [`position_in_stream`](https://qumranica.org/database/tables/position_in_stream.html) table encompass all the text of every edition in the entire database.  The [`sign`](https://qumranica.org/database/tables/sign.html) table is in no particular order, any sign could conceivably followed by any other.  It is the [`position_in_stream`](https://qumranica.org/database/tables/position_in_stream.html) table that provides this order in the form of a linked list, technically a DAG.  Note that [`position_in_stream`](https://qumranica.org/database/tables/position_in_stream.html) has an "owner" table, thus different [`edition`](https://qumranica.org/database/tables/edition.html)s can use different sign orderings.  This a bit more complex than a simple linked list, since each sign can link to more than one sign, thus creating branches of multiple alternate reading orders for a single [`edition`](https://qumranica.org/database/tables/edition.html).

### [position\_in\_stream](https://qumranica.org/database/tables/position_in_stream.html) table

|position\_in\_stream\_id|sign_id|next\_sign\_id|
|:--:|:--:|:--:|
|1|1|2|
|2|2|3|
|3|3|4|
|4|4|5|
|5|5|6|
|6|6|7|
|7|7|8|

We could, for instance add entries to the [`position_in_stream`](https://qumranica.org/database/tables/position_in_stream.html) table for an alternate branch of the reading stream:

|position\_in\_stream\_id|sign_id|next\_sign\_id|
|:--:|:--:|:--:|
|8|4|6|
|9|6|5|
|10|5|7|

Now we have the two possible reading orders: 1→2→3→4→5→6→7→8; and 1→2→3→4→6→5→7→8 assuming that all the `position_in_stream_id`s above are linked to the same `edition_editor_id` in the `position_in_stream_owner` table.  It is perfectly valid to have multiple possible reading orders.  An edition can set a preferred ordering in the `position_in_stream_owner`](https://qumranica.org/database/tables/position_in_stream_owner.html) table, which includes a boolean column `is_main`.

### linking signs to words, lines, text fragments, and editions

The individual signs positioned in the "sign stream" are linked to words and other multi-sign entities, `sign_stream_section`s, by the [`position_in_stream_to_section_rel`](https://qumranica.org/database/tables/position_in_stream_to_section_rel.html) table.  That table links individual `position_in_stream_id`s together into larger groupings, which can be linked to `word` entities in the Qumran Wöreterbuch Project database using the [`sign_stream_section_to_qwb_word`](https://qumranica.org/database/tables/sign_stream_section_to_qwb_word.html) table, or to textual parallels in other manuscripts via the [`parallel_sign_stream_section`](https://qumranica.org/database/tables/parallel_sign_stream_section.html) table.  Note that the parallels need not match complete words to other complete words, any group of letters (and spaces) can be matched to any other such collection.

The [`sign`](https://qumranica.org/database/tables/sign.html)s are also linked to [`line`](https://qumranica.org/database/tables/line.html)s in a edition via the [`sign_to_line`](https://qumranica.org/database/tables/sign_to_line.html) table, [`line`](https://qumranica.org/database/tables/line.html)s are linked to [`text_fragment`](https://qumranica.org/database/tables/text_fragment.html)s by the [`text_fragment_to_line`](https://qumranica.org/database/tables/text_fragment_to_line.html) table, and finally, [`text_fragment`](https://qumranica.org/database/tables/text_fragment.html)s are linked to [`manuscript`](https://qumranica.org/database/tables/manuscript.html)s via the [`manuscript_to_text_fragment`](https://qumranica.org/database/tables/manuscript_to_text_fragment.html) table.  All of these tables have their own "owner" tables and related "data" tables with their `name`s.  One note of caution about the designation [`text fragment`](https://qumranica.org/database/tables/col.html) in our database.  This label refers to several types of line groupings:

1.  A single column on a well-preserved multi-column manuscript (like 1QpHab col. 3)
2.  A single column on a edition manuscript fragment that has parts of more than one column (like 4Q417 frg. 4 which has two columns: 4Q417 frg. 4i and 4Q417 frg. 4ii)
3.  A single column made up of fragments that __may__ or __may not__ directly join to each other (like 4Q51 col. 3a-e)
4.  A single fragment with one section of text (like 4Q51 frg. 133)

Before we turn to the image data stored in the database, mention should be made of the [`sign_char_roi`](https://qumranica.org/database/tables/sign_char_roi.html), [`roi_shape`](https://qumranica.org/database/tables/roi_shape.html), and [`roi_position`](https://qumranica.org/database/tables/roi_position.html) tables.  These tables link [`sign_interpretation`](https://qumranica.org/database/tables/sign_interpretation.html)s in the database to spatial positions in the virtual manuscript, and thus create a binding between text and images (see [Binding text to image](#binding-text-to-image))

## Image data

The SQE database does not store any images, rather, it stores url's to images stored on other servers—mainly the iiif server of the IAA run by the NLI.  The information for these images is stored in the [`SQE_image`](https://qumranica.org/database/tables/SQE_image.html) table, which links to the [`image_urls`](https://qumranica.org/database/tables/image_urls.html) table for the server address.

### [SQE_image](https://qumranica.org/database/tables/SQE_image.html) table

|sqe\_image\_id|image\_urls\_id|filename|native_width|native_height|dpi|type|wavelength_start|wavelength_end|is_master|image_catalog_id|
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
|8346|2|P10-Fg001-R-C01-R01-D03062015-T110259-LR445_PSC.tif|7216|5412|1215|0|445|704|1|16056|
|8347|2|P10-Fg001-R-C01-R01-D03062015-T110406-LR924_012.jpg|7216|5412|1215|1|924|924|0|16056|
|8348|2|P10-Fg001-R-C01-R01-D03062015-T110523-OO_026.jpg|7216|5412|1215|2|924|924|0|16056|
|8349|2|P10-Fg001-R-C01-R01-D03062015-T110538-OO_028.jpg|7216|5412|1215|3|924|924|0|16056|

### [image_urls](https://qumranica.org/database/tables/image_urls.html) table

|image_urls_id|url|suffix|
|:--:|:--:|:--:|
|0|https://www.qumranica.org/cgi-bin/iipsrv.fcgi?IIIF=|default.jpg|
|1|http://gallica.bnf.fr/iiif/ark:/|native.jpg|
|2|http://192.114.7.208:8182/iiif/2/|default.jpg|

With this information we can get the full color image for the recto of IAA plate 1 fragment 1 using the [iiif image API syntax](http://iiif.io/api/image/2.1/) `http://192.114.7.208:8182/iiif/2/P10-Fg001-R-C01-R01-D03062015-T110259-LR445_PSC.tif/full/pct:5/0/default.jpg`.

![SQE image](http://192.114.7.208:8182/iiif/2/P10-Fg001-R-C01-R01-D03062015-T110259-LR445_PSC.tif/full/pct:5/0/default.jpg "SQE Image")

The [`SQE_image`](https://qumranica.org/database/tables/SQE_image.html) table stores the DPI of the image (these may have to be manually tuned, since the EXIF data cannot be relied upon).  It also stores the wavelength range of the image in nanometers, its dimensions in pixels, a type (0 for color; 1 for grayscale; 2 for raking light left, 3 for raking light right), and an `is_master` field).  Since we will often have several images of the same fragment, we use the highest resolution color image as the "master" images.  What this means is that all data about a fragment is keyed to that image alone (all other images are aligned with the "master" image via the [`image_to_image_map`](https://qumranica.org/database/tables/image_to_image.html) table).  This ensures consistency of reference.

The images in our database often have referencing data for these imaged objects provided by the imaging institution.  This data is found in the [`image_catalog`](https://qumranica.org/database/tables/image_catalog.html) table which the [`SQE_image`](https://qumranica.org/database/tables/SQE_image.html) table links to with the `image_catalog_id` field.

### [image_catalog](https://qumranica.org/database/tables/image_catalog.html) table

|image\_catalog\_id|institution|catalog\_number\_1|catalog\_number\_2|catalog_side|
|:--:|:--:|:--:|:--:|:--:|
|16056|IAA|10|1|0|
|16057|IAA|10|1|1|

This table provides the name of the imaging institution (here the IAA) and their cataloging numbers (here plate 10, fragment 1).  If the imaging institution has provided any bibliographical information, it is found in the [`iaa_edition_catalog`](https://qumranica.org/database/tables/iaa_edition_catalog.html) table, which is linked to the [`image_catalog`](https://qumranica.org/database/tables/image_catalog.html) in a many-to-many relationship via the [`image_to_iaa_edition_catalog`](https://qumranica.org/database/tables/image_to_iaa_edition_catalog.html) table.

Since we are working in SQE not with the full square images, but with cutouts containing only in image of the fragment itself, we store data about this "mask" in the database.  We never alter the images on the iiif servers themselves, rather, we perform transforms on them in the users' browsers.  This information is stored in several "artefact" tables.

We use the term "artefact" in order to differentiate what our editors are working with in comparison to what the imaging institutions are photographing.  For instance, the IAA calls anything that would remain together when picked up to be a "fragment".  This means that two pieces of a edition that have been taped together will be called a "fragment" regardless of whether the join is good or not.  We have generalized this terminology to "imaged object" to refer to what the imaging institution deems a coherent "object" for the purpose of imaging.  We use the term "artefact" to refer to what the editor considers to constitute a fully coherent piece of material.  Thus an SQE "artefact" will often be smaller than a "fragment" in the IAA parlance or the more general "imaged object", and it usually will not be bigger (though there are some cases where older photographs show that two fragments in the present were actually one in the past).

Each "artefact" receives a human readable name in the [`artefact_data`](https://qumranica.org/database/tables/artefact_data.html) table and has a vector polygon in the [`artefact_shape`](https://qumranica.org/database/tables/artefact_shape.html) table.  This vector polygon is stored in the MariaDB ["polygon"](https://mariadb.com/kb/en/library/polygon/) data type (MariaDB can import/export these polygons in [WKT](https://en.wikipedia.org/wiki/Well-known_text) or [GeoJSON](https://en.wikipedia.org/wiki/GeoJSON) formats).  The coordinates of that polygon correspond to the coordinate system of the "master" image, and thus can be used to directly create a mask in the "master" image.  The table [`artefact_position`](https://qumranica.org/database/tables/artefact_position.html) contains a rotation, scale, and translate that converts each points of the polygon in [`artefact_shape`](https://qumranica.org/database/tables/artefact_shape.html) to the coordinate system of the virtual manuscript. Thus each [`artefact_shape`](https://qumranica.org/database/tables/artefact_shape.html) can be translated, rotated, zoomed into any position on the virtual manuscript.

There is no "virtual manuscript" *per se* as an independent entity, the graphical components of "virtual manuscript" are simply the sum of all positioned objects belonging to an [`edition`](https://qumranica.org/database/tables/edition.html) (i.e., all artefacts and ROI's).  It has a theoretical resolution of 1215 DPI because most of our images have that resolution, and thus an imaginary coordinate system is based on that assumption.  Using a fixed global resolution enables the comparison of spacial edntities throughout the database.

## Binding text to image

The binding of text transcription to image in the SQE database is accomplished through the [`roi_position`](https://qumranica.org/database/tables/roi_position.html) table, which links directly to an artefact_id.  It defines the x and y translation necessary to locate the ROI in the coordinate system of the artefact. Each region of interest (ROI) has its own [`roi_shape`](https://qumranica.org/database/tables/roi_shape.html), and the  [`roi_position`](https://qumranica.org/database/tables/roi_position.html) and the [`roi_position`](https://qumranica.org/database/tables/roi_position.html) are linked to a [`sign_interpretation`](https://qumranica.org/database/tables/sign_sign_interpretation.html) via the [`sign_sign_interpretation_roi`](https://qumranica.org/database/tables/sign_sign_interpretation_roi.html) table. Through this direct connection between artefacts and ROI's, the further relationship of an [`artefact`](https://qumranica.org/database/tables/artefact.html) to a [`word`](https://qumranica.org/database/tables/word.html), [`line`](https://qumranica.org/database/tables/line.html) or [`col`](https://qumranica.org/database/tables/col.html)umn can be established.

Textual reconstructions can also be given spatial presence in the virtual manuscript by means of special artefacts called "virtual artefacts". A virtual artefact can have shape and position, just like a normal artefact, but they are not linked to any master image. Any reconstructed text can be created as a ROI linked to one of the imageless artefacts.  Artefacts may also be joined together into groups through the [`artefact_group_member`](https://qumranica.org/database/tables/artefact_group_member.html) table. As far as the database is concerned, these tables are purely informational, it is up to any consumer of the database to use these groupings as they see fit.  The intended use-case for the artefact group is that all members of an artefact group would move, scale, and rotate together.

__TODO__ Describe image stack and the artefact to artefact mapping.

## Sharing system

The database is designed to enabled multiple users to work in a shared space.  We have not yet planned a dedicated conflict resolution system, the initial offering will rely on other modes of communication between partners to resolve differences of opinion (probably by phone or email communication).  The system can, however, provide a full record of who made which changes and when, so the work of each member in a team is properly acknowledged and accounted for.

The sharing system works by means of the `edition`, which encompasses one or more individual `edition_editor` elements, each of which is linked to a specific user.  As such, the individual `edition_editor`s only provide the necessary data for a complete edition when taken in agregate.  When copying an edition, for instance, one must duplicate of every entry in the *x*_owner tables based on the `edition_id` and not any single `edition_editor_id`. Any updates or deletes to data in the database must also keep this in mind.  The data that a user is updating or deleting may not belong to her [`edition_editor`](https://qumranica.org/database/tables/edition_editor.html) at all, but rather to another [`edition_editor`](https://qumranica.org/database/tables/edition_editor.html) in the same `edition`.  This can easily be achieved by filtering on the `edition_id` column of the *x*_owner table instead of the individual `edition_editor_id`. When collecting data with a query, we must do the same thing and gather not only the data belonging to the [`edition_editor`](https://qumranica.org/database/tables/edition_editor.html) of the user, but all entries related to the [`edition`](https://qumranica.org/database/tables/edition.html).

## user permissions system

All editable data in the database is associate with a `user_id` created in the [`user`](https://qumranica.org/database/tables/user.html) table.

|user_id|user_name|pw|forename|surname|organization|email|registration_date|settings|last\_edition\_editor\_id|
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
|1|sqe_api|d60cd26b03a4607dc6c1db2514bbf20e59f751c98157c474ebfbeff3|||2017-08-20 18:59:50||1|
|5|test|7872a74bcbf298a1e77d507cd95d4f8d96131cbbd4cdfc571e776c8a|||2017-07-28 17:18:15||1|

All initial data in the database is associated with `user_id` 1. The initial editions using this data are all flagged as public in the [`edition`](https://qumranica.org/database/tables/edition.html) table and can be read by everyone, but changed by no one. We store only a sha256 hash of the user's password (perhaps we will switch to argon), thus we run no risk of disseminating user passwords.  All user passwords are sent over an SSL encrypted connection and are hashed server side.

Users may only write to data they own editions, that is, they can add/delete entries in *x*`_owner` tables that have an `edition_id` associated with an `edition_editor_id` connected to their `user_id`.  The [`edition`](https://qumranica.org/database/tables/edition.html) system opens up several possibilities for sharing.  Any user with the admin flag in their `edition_editor` entry has admin privileges for that [`edition`](https://qumranica.org/database/tables/edition.html).  With that status they are able to add new `edition_editor`s to an `edition` and also to restrict access of other `edition_editor`s to the `edition` through `may_write`, `may_lock`, and `may_read` fields in the [`edition_editor`](https://qumranica.org/database/tables/edition_editor.html) table. Editor requests are made by adding an entry to the [`edition_editor_request`](https://qumranica.org/database/tables/edition_editor_request.html) table.  This table stores the details of the user and permissions to be assigned along with a token.  The requested editor can submit the token in order to accept the request to become an editor (the corresponding entry in the [`edition_editor_request`](https://qumranica.org/database/tables/edition_editor_request.html) table should then be deleted).
