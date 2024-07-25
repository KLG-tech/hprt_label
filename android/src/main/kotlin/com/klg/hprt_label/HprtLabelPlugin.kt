package com.klg.hprt_label

import android.app.PendingIntent
import android.content.Context
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

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.channel = MethodChannel(flutterPluginBinding.binaryMessenger, "hprt_label")
        this.channel.setMethodCallHandler(this)
        this.context = flutterPluginBinding.getApplicationContext()
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
                if (HPRTPrinterHelper.IsOpened()) HPRTPrinterHelper.PortClose()
                mUsbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
                val deviceList = mUsbManager.deviceList
                val deviceIterator: Iterator<UsbDevice> = deviceList.values.iterator()
                var havePrinter = false
                while (deviceIterator.hasNext()) {
                    val currentDevice = deviceIterator.next()
                    if (currentDevice.deviceName.contains("hprt", true)) {
                        device = deviceIterator.next()
                        val count = device!!.interfaceCount
                        for (i in 0 until count) {
                            val intf = device!!.getInterface(i)
                            if (intf.interfaceClass == 7) {
                                havePrinter = true
                                if (!mUsbManager.hasPermission(device)) {
                                    mUsbManager.requestPermission(device, mPermissionIntent)
                                }
                            }
                        }
                    }
                }
                var resultConnect = -1
                if (havePrinter && device != null) {
                    resultConnect = HPRTPrinterHelper.PortOpen(context, device!!)
                    if (resultConnect == 0) {
                        HPRTPrinterHelper.printAreaSize("64", "18")
                        HPRTPrinterHelper.Offset("0")
                    }
                }
                if (resultConnect == 0) result.success("success") else result.success("failed")
            } else if (call.method.equals("requestUsbPermission", true)) {
                mUsbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
                val deviceList = mUsbManager.deviceList
                val deviceIterator: Iterator<UsbDevice> = deviceList.values.iterator()
                var havePrinter = false
                while (deviceIterator.hasNext()) {
                    val currentDevice = deviceIterator.next()
                    if (currentDevice.deviceName.contains("hprt", true)) {
                        device = deviceIterator.next()
                        val count = device!!.interfaceCount
                        for (i in 0 until count) {
                            val intf = device!!.getInterface(i)
                            if (intf.interfaceClass == 7) {
                                havePrinter = true
                                if (!mUsbManager.hasPermission(device)) {
                                    mUsbManager.requestPermission(device, mPermissionIntent)
                                }
                            }
                        }
                    }
                }
                result.success("success")
            } else {
                result.success("failed")
            }
        } catch (ex: Exception) {
            result.success("failed")
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
