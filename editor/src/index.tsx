/**
 * OperonEditor — Standalone BlockNote widget for Spalla/Operon Dashboard.
 *
 * Full feature set:
 * - Notion-style block editing (headings, lists, tables, code, media)
 * - Slash menu (/) for inserting any block type
 * - Formatting toolbar (bold, italic, underline, strikethrough, code, colors)
 * - Drag-and-drop block reordering
 * - Link editing
 * - Table manipulation (add/remove rows/columns)
 * - File/image upload via callback
 * - Markdown import/export
 * - Portuguese (pt-BR) localization
 * - Light/dark theme
 * - Read-only mode
 *
 * Usage from Alpine.js:
 *   OperonEditor.mount(el, {
 *     markdown: '# Hello',
 *     onChange: (md) => saveToSupabase(md),
 *     onUploadFile: (file) => uploadToS3(file),
 *     theme: 'light',
 *     readOnly: false,
 *     placeholder: 'Digite / para comandos...'
 *   })
 */

import React from "react";
import { createRoot, Root } from "react-dom/client";
import { OperonEditor, OperonEditorProps } from "./OperonEditor";

interface MountOptions {
  markdown?: string;
  placeholder?: string;
  readOnly?: boolean;
  onChange?: (markdown: string) => void;
  onUploadFile?: (file: File) => Promise<string>;
  theme?: "light" | "dark";
}

interface EditorInstance {
  root: Root;
  lastMarkdown: string;
  options: MountOptions;
}

const instances = new Map<HTMLElement, EditorInstance>();

function mount(container: HTMLElement, options: MountOptions = {}) {
  if (instances.has(container)) {
    unmount(container);
  }

  const instance: EditorInstance = {
    root: createRoot(container),
    lastMarkdown: options.markdown || "",
    options,
  };

  const handleChange = (md: string) => {
    instance.lastMarkdown = md;
    if (options.onChange) options.onChange(md);
  };

  instance.root.render(
    React.createElement(OperonEditor, {
      initialMarkdown: options.markdown || "",
      placeholder: options.placeholder,
      readOnly: options.readOnly || false,
      onChange: handleChange,
      onUploadFile: options.onUploadFile,
      theme: options.theme || "light",
    } as OperonEditorProps)
  );

  instances.set(container, instance);
  return { container };
}

function unmount(container: HTMLElement) {
  const instance = instances.get(container);
  if (instance) {
    instance.root.unmount();
    instances.delete(container);
    container.innerHTML = "";
  }
}

function getMarkdown(container: HTMLElement): string {
  const instance = instances.get(container);
  return instance ? instance.lastMarkdown : "";
}

function setMarkdown(container: HTMLElement, md: string) {
  const instance = instances.get(container);
  if (!instance) return;
  // Remount with new content, preserving options
  const opts = { ...instance.options, markdown: md };
  unmount(container);
  mount(container, opts);
}

function isActive(container: HTMLElement): boolean {
  return instances.has(container);
}

const api = { mount, unmount, getMarkdown, setMarkdown, isActive };
(window as any).OperonEditor = api;

export default api;
