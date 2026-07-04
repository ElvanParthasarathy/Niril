export const Bridge = {
  isAvailable: () => typeof window !== 'undefined' && (window as any).AndroidBridge !== undefined,
  
  onAppReady: () => {
    if (Bridge.isAvailable()) {
      (window as any).AndroidBridge.onAppReady();
    } else {
      console.log("[Bridge] onAppReady called (Not in Android WebView)");
    }
  }
};
