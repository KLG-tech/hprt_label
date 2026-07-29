package com.klg.hprt_label

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import androidx.core.util.SizeFCompat
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

    private val copy:Int = 1
    private var paperSize: SizeFCompat = SizeFCompat(52.0F, 23.0F)
    private val whitelist: List<String> = listOf("hprt", "print", "rt")

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.channel = MethodChannel(flutterPluginBinding.binaryMessenger, "hprt_label")
        this.channel.setMethodCallHandler(this)
        this.context = flutterPluginBinding.applicationContext
        this.mPermissionIntent = PendingIntent.getBroadcast(context, 0, Intent(ACTION_USB_PERMISSION), 0)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "connectIp" -> call.argument<String>("ipAddress")?.let { onConnectToIp(result, it) }
            "connectUsb" -> onConnectUsb(result)
            "printImage" -> onPrintImage(result, call.argument<ByteArray?>("byteData"))
            "requestUsbPermission" -> onRequestPermission(result)
            "setPaperSize" -> onSetPaperSize(result, call.argument<Float?>("width"), call.argument<Float?>("height"))
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun onConnectToIp(result: MethodChannel.Result, ipAddress: String) {
        if (HPRTPrinterHelper.IsOpened()) HPRTPrinterHelper.PortClose()
        val port = "9100"
        val resultConnect = HPRTPrinterHelper.PortOpen(context, "WiFi,$ipAddress,$port")
        if (resultConnect == 0) {
            setPrintAreaSizeAndOffset()
        }
        result.success(resultConnect == 0)
    }

    private fun onSetPaperSize(result: MethodChannel.Result, width:Float?, height: Float?) {
        try {
            val paperWidth:Float = width ?: 52.0F
            val paperHeight:Float = height ?: 23.0F

            paperSize = SizeFCompat(paperWidth, paperHeight)
            setPrintAreaSizeAndOffset()
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun onPrintImage(result: MethodChannel.Result, byte: ByteArray?) {
        try {
            val byteData: ByteArray? = byte
            val options = BitmapFactory.Options()
            options.inMutable = true
            val bmp = BitmapFactory.decodeByteArray(byteData, 0, byteData!!.size, options)
            HPRTPrinterHelper.CLS()
            setPrintAreaSizeAndOffset()
            val resultPrint = HPRTPrinterHelper.printImage(paperSize.width.toString(), paperSize.height.toString(), bmp, true, false, 0)
            HPRTPrinterHelper.Print(copy.toString(), copy.toString())
            if (HPRTPrinterHelper.IsOpened()) HPRTPrinterHelper.PortClose()
            result.success(resultPrint == 0)
        } catch (e: Exception) {
            result.error("400", e.message, e.message)
        }
    }

    private fun onConnectUsb(result: MethodChannel.Result) {
        mPermissionIntent = PendingIntent.getBroadcast(context, 0, Intent(ACTION_USB_PERMISSION), 0)
        mUsbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
        val deviceList = mUsbManager.deviceList
        var havePrinter = false

        for (it in deviceList.values) {
            val isHavePrinter: Boolean = checkDevice(it)
            if (isHavePrinter) {
                if (!mUsbManager.hasPermission(it)) {
                    mUsbManager.requestPermission(it, mPermissionIntent)
                } else {
                    device = it
                    havePrinter = true
                    break
                }
            }
        }

        var resultConnect = -1
        if (havePrinter && device != null) {
            if (HPRTPrinterHelper.IsOpened()) HPRTPrinterHelper.PortClose()
            resultConnect = HPRTPrinterHelper.PortOpen(context, device)
            if (resultConnect == 0) {
                setPrintAreaSizeAndOffset()
            }
        }
        result.success(resultConnect == 0)
    }

    private fun onRequestPermission(result: MethodChannel.Result) {
        try {
            mPermissionIntent = PendingIntent.getBroadcast(context, 0, Intent(ACTION_USB_PERMISSION), 0)
            mUsbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
            val deviceList = mUsbManager.deviceList

            for (it in deviceList.values) {
                val isHavePrinter = checkDevice(it)
                if (isHavePrinter) {
                    if (!mUsbManager.hasPermission(it)) {
                        mUsbManager.requestPermission(it, mPermissionIntent)
                    }
                }
            }

            result.success(true)
        } catch (e: Exception) {
            result.error("400", e.message, e.message)
        }
    }

    private fun setPrintAreaSizeAndOffset() {
        HPRTPrinterHelper.printAreaSize(paperSize.width.toString(), paperSize.height.toString())
        HPRTPrinterHelper.Offset("0")
    }

    private fun checkDevice(device: UsbDevice): Boolean {
        return whitelist.any {
            device.deviceName.contains(it, ignoreCase = true) || (device.manufacturerName
                    ?: "").contains(it, ignoreCase = true) || (device.productName
                    ?: "").contains(it, ignoreCase = true)
        }
    }
}
