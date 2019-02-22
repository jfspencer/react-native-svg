package com.example.ui

import android.content.Context
import android.graphics.Color
import android.graphics.PorterDuff
import android.view.ViewGroup
import android.widget.ImageView
import com.facebook.react.bridge.ReadableArray

//create a custom ImageView that does a string lookup on the bundle drawable index
//Primary Purpose is for rendering VectorDrawble xml files
class VectorImage(context: Context): ImageView(context) {

      //UI Init if needed
//    override fun onDraw(canvas: Canvas?) {
//        super.onDraw(canvas)
//    }

    //param[0] = icon name (String)
    //param[1] = size (String)
    //param[2] = tint color (String)
    

    fun setParams(props: ReadableArray) {
        //extract
        val id = context.applicationContext.resources.getIdentifier(props.getString(0), "drawable", context.applicationContext.packageName)
        this.setImageResource(id)
        this.adjustViewBounds = true
        if(props.getString(2).isNotEmpty()) this.setColorFilter(Color.parseColor(props.getString(2)), PorterDuff.Mode.SRC_IN)

        if(this.layoutParams != null){
            val surfaceParams: ViewGroup.LayoutParams = this.layoutParams as ViewGroup.LayoutParams
            surfaceParams.height = props.getString(1).toInt()
            surfaceParams.width = props.getString(1).toInt()
            this.layoutParams = surfaceParams
        }
        this.requestLayout()
    }
}