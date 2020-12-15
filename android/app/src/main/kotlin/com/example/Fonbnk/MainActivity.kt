package com.creadigol.wifisetup

import android.os.Bundle
import android.os.PersistableBundle
import android.telecom.Call
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.wifimap.locationclient.LatLng
import io.wifimap.sdk.ControlCenter
import io.wifimap.sdk.datacontroller.HotspotDataController
import io.wifimap.sdk.datacontroller.HotspotDataControllerListener
import io.wifimap.sdk.datacontroller.HotspotDataSort
import io.wifimap.sdk.errors.ControlCenterException
import io.wifimap.sdk.fetchcontroller.HotspotFetchController
import io.wifimap.sdk.fetchcontroller.HotspotFetchControllerSubscriber
import io.wifimap.sdk.fetchcontroller.HotspotFetchNetworkConnectionErrorDecision
import io.wifimap.sdk.fetchcontroller.HotspotFetchRequest
import io.wifimap.sdk.models.Hotspot
import io.wifimap.sdk.models.Location
import java.lang.Exception

class MainActivity: FlutterActivity, HotspotFetchControllerSubscriber,
        HotspotDataControllerListener {
    private val CHANNEL = "samples.flutter.dev/wifimap.sample"
    private var recentLocation: LatLng? = null
    private var fetchController: HotspotFetchController? = null
    private var dataController: HotspotDataController? = null
    private var resultSdk: MethodChannel.Result? = null

    constructor(){
        initSdk()
    }

    private val handler: MethodChannel.MethodCallHandler = MethodChannel.MethodCallHandler{
        call, result ->
        if (call.method == "fetch") {
            resultSdk = result;
            fetch(LatLng(call.argument<Double>("lat")!!, call.argument<Double>("lng")!!))

        } else {
            result.notImplemented()
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler(handler)
    }

    override fun onStop() {
        super.onStop()
        if (isFinishing) {
            fetchController?.unsubscribe(this)
            dataController?.stop()
            dataController?.listener = null
        }
    }

    private fun fetch(location: LatLng) {
        if(fetchController == null ) {
            initSdk()
            return
        }
        recentLocation = location
        fetchController?.performFetch(
                HotspotFetchRequest(
                        Location(
                                location.latitude,
                                location.longitude
                        )
                )
        )
    }

    fun initSdk(){
        ControlCenter.configure(
                this@MainActivity,
                "A0yc1thZG22lvzrvwVin542xvBople7t3YBTylPe",
                object : ControlCenter.CompletionListener {
                    override fun onComplete() {
                        try {
                            fetchController = ControlCenter.fetchController(this@MainActivity)
                            fetchController?.subscribe(this@MainActivity)
                            dataController = HotspotDataController(fetchController!!)
                            dataController?.listener = this@MainActivity
                            dataController?.applySorting(HotspotDataSort.Distance(true))
                            dataController?.start()

                        } catch (e: Exception) {
                            e.printStackTrace()
                        }
                    }

                    override fun onError(error: ControlCenterException) {
                        error.printStackTrace()
                    }
                })

    }
    override fun hotspotFetchController(controller: HotspotFetchController, updateCount: Int) {
        Log.d(TAG, "updateCount: $updateCount")
    }

    override fun hotspotFetchControllerDidBeginUpdate(controller: HotspotFetchController) {
        Log.d(TAG, "hotspotFetchControllerDidBeginUpdate")
    }

    override fun hotspotFetchControllerDidEndUpdate(controller: HotspotFetchController) {
        Log.d(TAG, "hotspotFetchControllerDidEndUpdate")
    }

    override fun hotspotFetchControllerDidFailWithInternalError(exception: Exception, controller: HotspotFetchController) {
        resultSdk?.error("1","hotspotFetchControllerDidFailWithInternalError", null)
    }

    override fun hotspotFetchControllerDidFailWithNetworkConnectionError(controller: HotspotFetchController): HotspotFetchNetworkConnectionErrorDecision {
        return HotspotFetchNetworkConnectionErrorDecision.retryWhenReachable
    }

    override fun hotspotDataController(controller: HotspotDataController, updateHotspots: List<Hotspot>) {
        Log.d(TAG, "${updateHotspots.size}")
        resultSdk?.success(updateHotspots.toString())
    }

    companion object {
        val TAG: String = MainActivity::class.java.simpleName
    }

}
