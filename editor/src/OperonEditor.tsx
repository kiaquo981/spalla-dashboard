import { useCreateBlockNote } from "@blocknote/react";
import { BlockNoteView } from "@blocknote/mantine";
import "@blocknote/mantine/style.css";
import { useEffect, useCallback, useRef } from "react";

export interface OperonEditorProps {
  initialMarkdown?: string;
  placeholder?: string;
  readOnly?: boolean;
  onChange?: (markdown: string) => void;
}

export function OperonEditor({
  initialMarkdown,
  placeholder,
  readOnly = false,
  onChange,
}: OperonEditorProps) {
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const editor = useCreateBlockNote({
    domAttributes: {
      editor: { class: "operon-bn-editor" },
    },
  });

  // Load initial markdown content
  useEffect(() => {
    if (initialMarkdown && editor) {
      (async () => {
        const blocks = await editor.tryParseMarkdownToBlocks(initialMarkdown);
        editor.replaceBlocks(editor.document, blocks);
      })();
    }
  }, [editor]); // Only on mount

  // Handle changes with debounce
  const handleChange = useCallback(() => {
    if (!onChange || readOnly) return;
    if (debounceRef.current) clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(async () => {
      const md = await editor.blocksToMarkdownLossy(editor.document);
      onChange(md);
    }, 300);
  }, [editor, onChange, readOnly]);

  return (
    <div className="operon-editor-root" data-operon-editor>
      <BlockNoteView
        editor={editor}
        editable={!readOnly}
        onChange={handleChange}
        theme="light"
      />
    </div>
  );
}
