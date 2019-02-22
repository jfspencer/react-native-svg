import UIKit

class VectorImage: UIView {
  //frame ref incase the UI is resized, the asset can maintain its size
  var imageCGRectRef: CGRect? = nil;
  let keyId: String = UUID().uuidString
  
  override init(frame: CGRect) {
    super.init(frame: frame);
    //init references
    imageCGRectRef = frame;

  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc func reactSetFrame(frame: CGRect) {
    /* everytime content size changes, you will get its frame here. */
    super.reactSetFrame(frame)
    self.frame = frame;
  }
  
  //RN prop native binding, pulls the asset and sets the UIImage and UIImageVIew frames
  //params array is an ordered string tuple
  @objc var params: [String] = [] {
    didSet {
      autoreleasepool{
        #if targetEnvironment(simulator)
          let start = DispatchTime.now()
        #endif
        let name = params[0]
        if Bundle.main.url(forResource: name, withExtension: "svg") != nil {
          if let newImage = SVGKImage.init(named: name + ".svg", withCacheKey: keyId.replacingOccurrences(of: "-", with: "")) {
            let size = Double(params[1]) ?? 400 //make the default an abviously wrong value for quick diagnosis on the UI
            let color = params[2]
            let aspectW = Double(params[3]) ?? 1 //if this is missing make the aspect something that is obviously wrong on the UI
            let aspectH = Double(params[4]) ?? 8 //if this is missing make the aspect something that is obviously wrong on the UI
            let outerFrame = CGRect(x: 0, y: 0, width: size, height: size)
            let svgFrame = getSVGAspectCGRect(size: size, aspW: aspectW, aspH: aspectH)
            self.subviews.forEach { $0.removeFromSuperview() }
            if let vectorBox = SVGKFastImageView.init(svgkImage: newImage) {
              if(color.count > 0) {vectorBox.setTintColor(color: hexToUIColor(hex: color))}
              vectorBox.frame = svgFrame
              self.addSubview(vectorBox)
              self.frame = outerFrame
              #if targetEnvironment(simulator)
                let end = DispatchTime.now()
                let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
              let timeInterval = "Render time: " + String(Double(nanoTime) / 1_000_000) + "ms"
              print("------------------>>>>> VectorImage Params: ", name, size, color, aspectW, aspectH, timeInterval)
              #endif
            }
          }
          else {
            #if targetEnvironment(simulator)
              print("--------->>>>> Found SVG, failed to init:", params[0], params[1], params[2], params[3], params[4])
            #endif
          }
        }
        else {
          #if targetEnvironment(simulator)
            //It is a programming error to call for an SVG that has not been added to Xcode
            fatalError("This SVG Icon was not found in Xcode: " + name)
          #endif
        }
      }
    }
  }
  
  private func getSVGAspectCGRect(size: Double, aspW: Double, aspH: Double) -> CGRect {
    let aspectRatio = aspW / aspH
    return aspW > aspH ?
      CGRect(x: 0, y: (size - size / aspectRatio) / 2, width: size, height: size / aspectRatio)
    : CGRect(x: (size - size * aspectRatio) / 2, y: 0, width: size * aspectRatio, height: size)
  }
  
  private func hexToUIColor(hex: String) -> UIColor {
    let rgb = buildCGFloatRGB(hex: hex)
    return UIColor(red: rgb[0], green: rgb[1], blue: rgb[2], alpha: CGFloat(1))
  }
  
  private func buildCGFloatRGB(hex: String) -> [CGFloat] {
    let nHex = hex.replacingOccurrences(of: "#", with: "")
    if(nHex.count == 3) {return [hexToCGFloat(hexPart: nHex[0 ..< 1]), hexToCGFloat(hexPart: nHex[1 ..< 2]), hexToCGFloat(hexPart: nHex[2 ..< 3])]}
    return [hexToCGFloat(hexPart: nHex[0 ..< 2]), hexToCGFloat(hexPart: nHex[2 ..< 4]), hexToCGFloat(hexPart: nHex[4 ..< 6])]
  }
  
  private func hexToCGFloat(hexPart: String) -> CGFloat {
    if let hexInt = Int(hexPart.count == 1 ? hexPart + "" + hexPart : hexPart, radix: 16) {
      return CGFloat(Float(hexInt) / 255.0)
    }
    else { return CGFloat(0); }
  }
}

extension SVGKImageView {
  
  func setTintColor(color: UIColor) {
    if self.image != nil && self.image.caLayerTree != nil {
      changeFillColorRecursively(sublayers: self.image.caLayerTree.sublayers, color: color)
    }
  }
  
  private func changeFillColorRecursively(sublayers: [AnyObject]?, color: UIColor) {
    if let sublayers = sublayers {
      for layer in sublayers {
        if let l = layer as? CAShapeLayer {
          if l.strokeColor != nil {
            l.strokeColor = color.cgColor
          }
          if l.fillColor != nil {
            l.fillColor = color.cgColor
          }
        }
        if let l = layer as? CALayer, let sub = l.sublayers {
          changeFillColorRecursively(sublayers: sub, color: color)
        }
      }
    }
  }
}
