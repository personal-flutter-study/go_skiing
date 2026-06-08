package com.example.go_skiing_poc_2

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.SoundPool
import android.os.Build
import android.os.Vibrator
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    var vibrator: Vibrator? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {



        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.go_skiing_poc_2_m"
        ).setMethodCallHandler { call, result ->

            vibrator = context.getSystemService(Vibrator::class.java)



            when (call.method) {

                "vibrate" -> {
                    vibrator?.vibrate(1000)
                    result.success(true)
                    return@setMethodCallHandler
                }

            }


            result.notImplemented()

        }


        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.go_skiing_poc_2_e"
        ).setStreamHandler(object : EventChannel.StreamHandler, SensorEventListener {

            lateinit var sensorManager: SensorManager
            var sensor: Sensor? = null
            var eventSink: EventChannel.EventSink? = null

            override fun onListen(
                p0: Any?,
                p1: EventChannel.EventSink?
            ) {

                eventSink = p1

                sensorManager = context.getSystemService(SensorManager::class.java)
                sensor = sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
                sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_GAME)
            }

            override fun onCancel(p0: Any?) {
                sensorManager.unregisterListener(this)
            }

            override fun onAccuracyChanged(p0: Sensor?, p1: Int) {}

            override fun onSensorChanged(p0: SensorEvent?) {
                eventSink?.success(p0?.values[2])
            }
        })



        super.configureFlutterEngine(flutterEngine)
    }


}
