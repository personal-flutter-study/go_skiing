package com.example.go_sking_poc_1

import android.content.res.AssetManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.media.MediaPlayer
import android.media.SoundPool
import android.os.Build
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {


    var mediaPlayer: MediaPlayer? = null
    val soundPool = SoundPool.Builder().setMaxStreams(2).build()
    val loadedSounds = mutableMapOf<String, Int>()

    lateinit var flutterLoader: FlutterLoader
    lateinit var assetManager: AssetManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        flutterLoader = FlutterInjector.instance().flutterLoader()
        assetManager = context.assets

        val coin = flutterLoader.getLookupKeyForAsset("assets/audio/coin.wav")
        val jump = flutterLoader.getLookupKeyForAsset("assets/audio/jump.wav")
        val bgm = flutterLoader.getLookupKeyForAsset("assets/audio/bgm.mp3")
        val gameOver = flutterLoader.getLookupKeyForAsset("assets/audio/game_over.wav")

        val coinFd = assetManager.openFd(coin)
        val coinId = soundPool.load(coinFd, 0)
        coinFd.close()

        val jumpFd = assetManager.openFd(jump)
        val jumpId = soundPool.load(jumpFd, 0)
        jumpFd.close()

        soundPool.setOnLoadCompleteListener { soundPool, i, i1 ->
            if (i1 == 0) {
                if (coinId == i) {
                    loadedSounds["coin"] = i
                }
                if (jumpId == i) {
                    loadedSounds["jump"] = i
                }
            }
        }


        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com/example/go_sking_poc_1_method"
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "coin" -> {
                    loadedSounds["coin"]?.let {
                        soundPool.play(it, 1F, 1F, 0, 0, 1F)
                        result.success(true)
                        return@setMethodCallHandler
                    }
                }

                "jump" -> {
                    loadedSounds["jump"]?.let {
                        soundPool.play(it, 1F, 1F, 0, 0, 1F)
                        result.success(true)
                        return@setMethodCallHandler
                    }
                }

                "start" -> {
                    val bgmFd = assetManager.openFd(bgm)
                    mediaPlayer?.release()
                    mediaPlayer =
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                            MediaPlayer(context)
                        } else {
                            MediaPlayer()
                        }
                    mediaPlayer?.setDataSource(bgmFd)
                    bgmFd.close()
                    mediaPlayer?.isLooping = true
                    mediaPlayer?.setOnPreparedListener { it.start(); result.success(true) }
                    mediaPlayer?.prepareAsync()
                    return@setMethodCallHandler
                }

                "volume" -> {
                    val volume = (call.arguments<Double>() ?: 1.0).toFloat()
                    mediaPlayer?.setVolume(volume, volume)

                }

                "play" -> {
                    mediaPlayer?.start()
                }

                "stop" -> {
                    mediaPlayer?.pause()
                }

                "gameOver" -> {
                    mediaPlayer?.stop()
                    mediaPlayer?.release()
                    mediaPlayer = null

                    val gameOverFd = assetManager.openFd(gameOver)
                    mediaPlayer =
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                            MediaPlayer(context)
                        } else {
                            MediaPlayer()
                        }
                    mediaPlayer?.setDataSource(gameOverFd)
                    gameOverFd.close()
                    mediaPlayer?.setOnPreparedListener { it.start(); result.success(true) }
                    mediaPlayer?.prepareAsync()
                    return@setMethodCallHandler

                }

                "quit" -> {
                    mediaPlayer?.stop()
                    mediaPlayer?.release()
                    mediaPlayer = null
                    result.success(true)
                    return@setMethodCallHandler
                }

            }


            result.notImplemented()


        }


        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com/example/go_sking_poc_1_event"
        ).setStreamHandler(object : EventChannel.StreamHandler {

            lateinit var sensorManager: SensorManager
            lateinit var sensorEventListener: SensorEventListener

            override fun onListen(
                p0: Any?,
                sink: EventChannel.EventSink?
            ) {
                sensorManager = getSystemService(SensorManager::class.java)
                val sensor = sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)


                sensorEventListener = object : SensorEventListener {
                    override fun onAccuracyChanged(p0: Sensor?, p1: Int) {}

                    override fun onSensorChanged(event: SensorEvent?) {
                        event?.values?.let { sink?.success(it[2]) }
                    }
                }

                sensorManager.registerListener(
                    sensorEventListener,
                    sensor,
                    SensorManager.SENSOR_DELAY_GAME
                )


            }

            override fun onCancel(p0: Any?) {
                sensorManager.unregisterListener(sensorEventListener)
            }
        })


    }

}
