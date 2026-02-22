package cafe.bonfire.desktop

import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat

class MainActivity : TauriActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    enableEdgeToEdge()
    super.onCreate(savedInstanceState)

    // Apply native top padding for the status bar.
    // env(safe-area-inset-top) returns 0 in Android WebView,
    // so we handle it at the native level instead.
    ViewCompat.setOnApplyWindowInsetsListener(window.decorView) { view, insets ->
      val statusBar = insets.getInsets(WindowInsetsCompat.Type.statusBars())
      view.setPadding(0, statusBar.top, 0, 0)
      insets
    }
  }
}
