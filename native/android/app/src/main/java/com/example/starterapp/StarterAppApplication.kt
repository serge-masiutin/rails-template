package com.example.starterapp

import android.app.Application
import dev.hotwire.core.config.Hotwire
import dev.hotwire.core.turbo.config.PathConfiguration
import dev.hotwire.navigation.config.registerFragmentDestinations

class StarterAppApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        Hotwire.config.applicationUserAgentPrefix = "StarterApp;"
        Hotwire.config.webViewDebuggingEnabled = BuildConfig.DEBUG
        Hotwire.registerFragmentDestinations(WebFragment::class, WebBottomSheetFragment::class)
        Hotwire.loadPathConfiguration(
            context = this,
            location = PathConfiguration.Location(
                assetFilePath = "json/android_v1.json",
                remoteFileUrl = "${BuildConfig.BASE_URL}/configurations/android_v1.json"
            )
        )
    }
}
