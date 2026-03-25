/**
 * OperonEditor — Full-featured BlockNote editor for Spalla/Operon.
 *
 * Features enabled:
 * - All block types (headings, lists, tables, code, images, files, audio, video)
 * - Slash menu (/) with all block types
 * - Formatting toolbar (bold, italic, underline, strikethrough, code, colors)
 * - Side menu with drag-and-drop reordering
 * - Link toolbar
 * - Table handles (add/remove rows/columns)
 * - File upload (via callback to host app)
 * - Markdown import/export
 * - Placeholder text
 * - Read-only mode
 * - Light/dark theme support
 * - Localization (pt-BR)
 */

import { useCreateBlockNote } from "@blocknote/react";
import { BlockNoteView } from "@blocknote/mantine";
import "@blocknote/core/fonts/inter.css";
import "@blocknote/mantine/style.css";
import { useEffect, useCallback, useRef } from "react";
import type { BlockNoteEditor } from "@blocknote/core";
import { pt } from "@blocknote/core/locales";

export interface OperonEditorProps {
  initialMarkdown?: string;
  placeholder?: string;
  readOnly?: boolean;
  onChange?: (markdown: string) => void;
  onUploadFile?: (file: File) => Promise<string>;
  theme?: "light" | "dark";
}

export function OperonEditor({
  initialMarkdown,
  placeholder,
  readOnly = false,
  onChange,
  onUploadFile,
  theme = "light",
}: OperonEditorProps) {
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const editorRef = useRef<BlockNoteEditor | null>(null);

  const editor = useCreateBlockNote({
    // Localization
    dictionary: pt,

    // Placeholder
    domAttributes: {
      editor: {
        class: "operon-bn-editor",
        "data-placeholder": placeholder || "Digite / para comandos...",
      },
    },

    // File upload handler — delegates to host app
    uploadFile: onUploadFile || undefined,
  });

  // Store ref for external access
  editorRef.current = editor;

  // Load initial markdown content
  useEffect(() => {
    if (initialMarkdown && editor) {
      (async () => {
        try {
          const blocks = await editor.tryParseMarkdownToBlocks(initialMarkdown);
          editor.replaceBlocks(editor.document, blocks);
        } catch (e) {
          console.warn("[OperonEditor] Failed to parse markdown:", e);
        }
      })();
    }
  }, [editor]); // Only on mount

  // Cleanup debounce on unmount
  useEffect(() => {
    return () => {
      if (debounceRef.current) clearTimeout(debounceRef.current);
    };
  }, []);

  // Handle changes with debounce
  const handleChange = useCallback(() => {
    if (!onChange || readOnly) return;
    if (debounceRef.current) clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(async () => {
      try {
        const md = await editor.blocksToMarkdownLossy(editor.document);
        onChange(md);
      } catch (e) {
        console.warn("[OperonEditor] Failed to serialize markdown:", e);
      }
    }, 300);
  }, [editor, onChange, readOnly]);

  return (
    <div className="operon-editor-root" data-operon-editor>
      <BlockNoteView
        editor={editor}
        editable={!readOnly}
        onChange={handleChange}
        theme={theme}
        // All UI components enabled by default:
        // - formattingToolbar (bold, italic, colors, etc.)
        // - slashMenu (/ commands for all block types)
        // - sideMenu (drag handle + add block button)
        // - linkToolbar (edit/remove links)
        // - tableHandles (add/remove rows/columns)
        // - filePanel (upload interface)
      />
    </div>
  );
}
