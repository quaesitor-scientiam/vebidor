/* global React, ReactDOM, MarketingNav, Hero, FeatureGrid, BrowserMatrix, PhasesTimeline, MarketingFooter */

function App() {
  return (
    <>
      <MarketingNav />
      <Hero />
      <FeatureGrid />
      <BrowserMatrix />
      <PhasesTimeline />
      <MarketingFooter />
    </>
  );
}

ReactDOM.createRoot(document.getElementById("root")).render(<App />);
