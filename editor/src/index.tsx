/**
 * OperonEditor — Standalone BlockNote widget for Spalla/Operon Dashboard.
 *
 * Exposes window.OperonEditor with imperative API for Alpine.js integration.
 * React is bundled inside — the host page does NOT need React.
 *
 * Usage from Alpine.js:
 *   OperonEditor.mount(el, { markdown: '# Hello', onChange: (md) => console.log(md) })
 *   OperonEditor.unmount(el)
 *   OperonEditor.getMarkdown(el)
 *   OperonEditor.setMarkdown(el, '# New content')
 */

import React from "react";
import { createRoot, Root } from "react-dom/client";
import { OperonEditor, OperonEditorProps } from "./OperonEditor";

interface EditorInstance {
  root: Root;
  editorRef: { getMarkdown: () => Promise<string>; setMarkdown: (md: string) => void } | null;
  lastMarkdown: string;
}

const instances = new Map<HTMLElement, EditorInstance>();

/**
 * Mount a BlockNote editor inside a container element.
 */
function mount(
  container: HTMLElement,
  options: {
    markdown?: string;
    placeholder?: string;
    readOnly?: boolean;
    onChange?: (markdown: string) => void;
    theme?: "light" | "dark";
  } = {}
) {
  // Unmount existing instance if any
  if (instances.has(container)) {
    unmount(container);
  }

  const instance: EditorInstance = {
    root: createRoot(container),
    editorRef: null,
    lastMarkdown: options.markdown || "",
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
    } as OperonEditorProps)
  );

  instances.set(container, instance);
  return { container };
}

/**
 * Unmount editor from a container.
 */
function unmount(container: HTMLElement) {
  const instance = instances.get(container);
  if (instance) {
    instance.root.unmount();
    instances.delete(container);
    container.innerHTML = "";
  }
}

/**
 * Get current Markdown from an editor instance.
 */
function getMarkdown(container: HTMLElement): string {
  const instance = instances.get(container);
  return instance ? instance.lastMarkdown : "";
}

/**
 * Set Markdown content on an editor instance (remounts).
 */
function setMarkdown(container: HTMLElement, md: string) {
  const instance = instances.get(container);
  if (!instance) return;

  // Get current options from the instance and remount
  const currentOnChange = instance.lastMarkdown; // preserve callback via closure
  instance.lastMarkdown = md;

  // Remount with new content
  instance.root.unmount();
  instance.root = createRoot(container);
  instance.root.render(
    React.createElement(OperonEditor, {
      initialMarkdown: md,
      readOnly: false,
      onChange: (newMd: string) => {
        instance.lastMarkdown = newMd;
      },
    } as OperonEditorProps)
  );
}

/**
 * Check if an element has an active editor.
 */
function isActive(container: HTMLElement): boolean {
  return instances.has(container);
}

// Expose on window
const api = { mount, unmount, getMarkdown, setMarkdown, isActive };
(window as any).OperonEditor = api;

export default api;
