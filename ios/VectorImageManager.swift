import Foundation

//manager class that returns instances of VectorImage
@objc(VectorImageManager)
class VectorImageManager: RCTViewManager {
  override func view() -> UIView! {
    //UIVIew is framed on init with 0 size. prop setting reframes to the proper size
    return VectorImage(frame: CGRect(x: 0,y: 0, width:0, height: 0));
  }
  
  //run brdige binding on the UI thread to ensure the native code is ready when needed
  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
}
