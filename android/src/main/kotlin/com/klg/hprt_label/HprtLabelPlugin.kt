package com.klg.hprt_label

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import tspl.HPRTPrinterHelper

/** HprtLabelPlugin */
class HprtLabelPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    //USB
    private lateinit var mUsbManager: UsbManager
    private var device: UsbDevice? = null
    private lateinit var mPermissionIntent: PendingIntent
    private val ACTION_USB_PERMISSION = "com.android.example.USB_PERMISSION"

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.channel = MethodChannel(flutterPluginBinding.binaryMessenger, "hprt_label")
        this.channel.setMethodCallHandler(this)
        this.context = flutterPluginBinding.getApplicationContext()
        this.mPermissionIntent = PendingIntent.getBroadcast(context, 0, Intent(ACTION_USB_PERMISSION), 0)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            if (call.method.equals("connectIp", true)) {
                if (HPRTPrinterHelper.IsOpened()) HPRTPrinterHelper.PortClose()
                val ipAddress: String? = call.argument<String?>("ipAddress") ?: throw Exception("failed")
                val port = "9100"
                val resultConnect = HPRTPrinterHelper.PortOpen(context, "WiFi,$ipAddress,$port")
                if (resultConnect == 0) {
                    HPRTPrinterHelper.printAreaSize("60", "23")
                    HPRTPrinterHelper.Offset("0")
                }
                if (resultConnect == 0) result.success("success") else result.success("failed")

            } else if (call.method.equals("printImage", true)) {
                val byteData: ByteArray? = call.argument<ByteArray?>("byteData") ?: throw Exception("failed")
                val options = BitmapFactory.Options()
                options.inMutable = true
                val bmp = BitmapFactory.decodeByteArray(byteData, 0, byteData!!.size, options)
                HPRTPrinterHelper.CLS()
                HPRTPrinterHelper.printAreaSize("60", "23")
                HPRTPrinterHelper.Offset("0")
                val resultPrint = HPRTPrinterHelper.printImage("60", "23", bmp, true, false, 0)
                HPRTPrinterHelper.Print("1", "1")
                if (HPRTPrinterHelper.IsOpened()) HPRTPrinterHelper.PortClose()
                if (resultPrint == 0) result.success("success") else result.success("failed")

            } else if (call.method.equals("connectUsb", true)) {
                mPermissionIntent = PendingIntent.getBroadcast(context, 0, Intent(ACTION_USB_PERMISSION), 0)
                mUsbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
                val deviceList = mUsbManager.deviceList
                var havePrinter = false
                deviceList.values.iterator().forEach {
                    val deviceName = it.deviceName
                    val deviceManufactureName = it.manufacturerName ?: ""
                    val productName = it.productName ?: ""
                    if (deviceName.contains("hprt", true) || deviceManufactureName.contains("hprt", true) || productName.contains("hprt", true) ||
                        deviceName.contains("print", true) || deviceManufactureName.contains("print", true) || productName.contains("print", true) ||
                        deviceName.contains("rt", true) || deviceManufactureName.contains("rt", true) || productName.contains("rt", true)
                    ) {
                        if (!mUsbManager.hasPermission(it)) {
                            mUsbManager.requestPermission(it, mPermissionIntent)
                        } else {
                            device = it
                            havePrinter = true
                        }
                    }
                }
                var resultConnect = -1
                if (havePrinter && device != null) {
                    if (HPRTPrinterHelper.IsOpened()) HPRTPrinterHelper.PortClose()
                    resultConnect = HPRTPrinterHelper.PortOpen(context, device)
                    if (resultConnect == 0) {
                        HPRTPrinterHelper.printAreaSize("64", "18")
                        HPRTPrinterHelper.Offset("0")
                    }
                }
                if (resultConnect == 0) result.success("success") else result.success("failed")

            } else if (call.method.equals("requestUsbPermission", true)) {
                mPermissionIntent = PendingIntent.getBroadcast(context, 0, Intent(ACTION_USB_PERMISSION), 0)
                mUsbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
                val deviceList = mUsbManager.deviceList
                deviceList.values.iterator().forEach {
                    val deviceName = it.deviceName
                    val deviceManufactureName = it.manufacturerName ?: ""
                    val productName = it.productName ?: ""
                    if (deviceName.contains("hprt", true) || deviceManufactureName.contains("hprt", true) || productName.contains("hprt", true) ||
                        deviceName.contains("print", true) || deviceManufactureName.contains("print", true) || productName.contains("print", true) ||
                        deviceName.contains("rt", true) || deviceManufactureName.contains("rt", true) || productName.contains("rt", true)
                    ) {
                        if (!mUsbManager.hasPermission(it)) {
                            mUsbManager.requestPermission(it, mPermissionIntent)
                        }
                    }
                }
                result.success("success")

            } else {
                result.success("failed")
            }
        } catch (ex: Exception) {
            result.success(ex.toString())
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
