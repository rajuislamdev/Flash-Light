package com.example.flashlight_app

import android.content.Context
import android.hardware.camera2.CameraAccessException
import android.hardware.camera2.CameraManager
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel


/**
 * The main activity of the app.
 *
 * It handles the configuration of the Flutter engine and the communication with the camera.
 */
class MainActivity: FlutterActivity(){
    // The channel names for MethodChannel and EventChannel
    private val channel = "com.example.flashlight_app/flashlight"
    private val eventChannel = "com.example.flashlight_app/flashlight_event"
    // The state of the flashlight
    private var isFlashOn = false
    // The event sink for EventChannel
    private var eventSink: EventChannel.EventSink? = null


    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Set the method call handler for MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,channel).setMethodCallHandler{
            call, result ->
            if(call.method == "toggleFlashlight"){
               toggleFlashlight()
                result.success(null)
            }
         }

        // Set the stream handler for EventChannel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger,eventChannel).setStreamHandler(
            object : EventChannel.StreamHandler{
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
        
        // Register the torch callback for the camera
        val cameraManager = getSystemService(Context.CAMERA_SERVICE) as CameraManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            cameraManager.registerTorchCallback(object : CameraManager.TorchCallback(){
                override fun onTorchModeChanged(cameraId: String, enabled: Boolean) {
                    super.onTorchModeChanged(cameraId, enabled)
                    isFlashOn = enabled
                    eventSink?.success(enabled)
                }

                override fun onTorchModeUnavailable(cameraId: String) {
                    super.onTorchModeUnavailable(cameraId)
                    eventSink?.success(false)
                }
            }, null)
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun toggleFlashlight(){
        // Get the camera manager and toggle the flashlight state
        val cameraManager = getSystemService(Context.CAMERA_SERVICE) as CameraManager
        return try {
            val cameraId = cameraManager.cameraIdList[0]
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                cameraManager.setTorchMode(cameraId ,!isFlashOn)
            } else {
                throw UnsupportedOperationException("Flashlight control requires Android Marshmallow or higher")
            }


        } catch (e: CameraAccessException){
            e.printStackTrace()


        }
    }
}

