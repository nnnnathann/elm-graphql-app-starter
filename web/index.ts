declare global {
  interface ElmInput {
    node: HTMLElement;
    flags?: {};
  }
  interface GotDimensions {
    _tag: "GotDimensions";
    dimensions: {
      width: number;
      height: number;
    };
  }
  type FromBackendMsg = GotDimensions;
  type ToBackendMsg = {};

  interface ElmApp {
    ports: {
      fromBackend: { send: (msg: FromBackendMsg) => void };
      toBackend: (msg: ToBackendMsg) => void;
    };
  }

  interface Window {
    Elm: {
      Main: {
        init: (input: ElmInput) => ElmApp;
      };
    };
  }
}

import "./index.postcss";

let app: ElmApp;

const observer = new ResizeObserver(([entries]) => {
  const contentRect = entries.contentRect;
  const width = parseFloat(contentRect.width as any);
  const height = parseFloat(contentRect.height as any);
  if (!app) {
    app = window.Elm.Main.init({
      node: document.getElementById("root")!,
      flags: {
        dimensions: { width, height },
      },
    });
  } else {
    app.ports.fromBackend.send({
      _tag: "GotDimensions",
      dimensions: { width, height },
    });
  }
});

observer.observe(document.getElementById("root-container"));

export {};
