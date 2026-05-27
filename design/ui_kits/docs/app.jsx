/* global React, ReactDOM, TopNav, Sidebar, TocPanel, DocsPage, DOCS_PAGES_TOC */
const { useState } = React;

const PAGES = [
  { id: "quick-start", title: "Quick start",    section: "Getting started" },
  { id: "install",     title: "Installation",   section: "Getting started" },
  { id: "config",      title: "Configuration",  section: "Getting started" },
  { id: "modern-api",  title: "Modern API",     section: "API reference", chip: "new" },
  { id: "locators",    title: "Locators",       section: "API reference" },
  { id: "selectors",   title: "Selector engines",section: "API reference" },
  { id: "assertions",  title: "Assertions",     section: "API reference" },
  { id: "bidi",        title: "WebDriver-BiDi", section: "API reference" },
  { id: "mobile",      title: "Mobile",         section: "Roadmap",   chip: "preview" },
  { id: "comparison",  title: "Comparison",     section: "Reference" },
  { id: "changelog",   title: "Changelog",      section: "Reference" },
];

function App() {
  const [activeId, setActiveId] = useState("quick-start");

  return (
    <>
      <TopNav onSearchFocus={() => {}} />
      <div className="topnav-spacer" />
      <div className="shell">
        <Sidebar pages={PAGES} activeId={activeId} onSelect={setActiveId} />
        <main className="main">
          <DocsPage pageId={activeId} />
        </main>
        <div className="toc-col">
          <TocPanel items={DOCS_PAGES_TOC(activeId)} />
        </div>
      </div>
    </>
  );
}

ReactDOM.createRoot(document.getElementById("root")).render(<App />);
