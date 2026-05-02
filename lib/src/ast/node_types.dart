/// String constants for every node `type` discriminator. Mirrors
/// `markast.ast.types.NodeType` on the Python side — any parser that follows
/// the same convention is compatible.
class NodeType {
  NodeType._();

  // ── Document ──────────────────────────────────────────────────────
  static const document = 'document';

  // ── Block ─────────────────────────────────────────────────────────
  static const heading     = 'heading';
  static const paragraph   = 'paragraph';
  static const blockquote  = 'blockquote';
  static const codeBlock   = 'code_block';
  static const image       = 'image';
  static const video       = 'video';
  static const list        = 'list';
  static const listItem    = 'list_item';
  static const table       = 'table';
  static const tableHead   = 'table_head';
  static const tableBody   = 'table_body';
  static const tableRow    = 'table_row';
  static const tableCell   = 'table_cell';
  static const divider     = 'divider';
  static const widget      = 'widget';
  static const htmlBlock   = 'html_block';
  static const footnoteDef = 'footnote_def';

  // ── Inline ────────────────────────────────────────────────────────
  static const text        = 'text';
  static const bold        = 'bold';
  static const italic      = 'italic';
  static const boldItalic  = 'bold_italic';
  static const codeInline  = 'code_inline';
  static const link        = 'link';
  static const strikethrough = 'strikethrough';
  static const underline   = 'underline';
  static const inlineImage = 'inline_image';
  static const softbreak   = 'softbreak';
  static const hardbreak   = 'hardbreak';
  static const footnoteRef = 'footnote_ref';

  static const inlineTypes = <String>{
    text, bold, italic, boldItalic, codeInline, link,
    strikethrough, underline, inlineImage, softbreak, hardbreak, footnoteRef,
  };

  static const blockTypes = <String>{
    heading, paragraph, blockquote, codeBlock, image, video,
    list, listItem, table, tableHead, tableBody, tableRow, tableCell,
    divider, widget, htmlBlock, footnoteDef,
  };
}
