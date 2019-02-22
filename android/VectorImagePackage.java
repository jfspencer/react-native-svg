package com.example.ui;

import android.support.annotation.Nullable;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewManager;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

//This class is registered in MainApplication
public class VectorImagePackage implements ReactPackage {
    @Override
    public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
        return Arrays.<ViewManager>asList(
                new VectorImageManager()
        );
    }

    @Override
    public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
        return Collections.emptyList();
    }
}

//This singleton class manages all instances of the Native UI component
//it is registered in the Package class above
class VectorImageManager extends SimpleViewManager<VectorImage> {

    private static final String REACT_CLASS = "VectorImage";

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    public VectorImage createViewInstance(ThemedReactContext context) {
        return new VectorImage(context);
    }

    @ReactProp(name = "params")
    public void setParams(VectorImage view,@Nullable ReadableArray sources) {
        if(sources != null) view.setParams(sources);
    }
}


