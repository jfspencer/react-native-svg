#import "React/RCTViewManager.h"

@interface
//Macros that exposes native code with RN
RCT_EXTERN_MODULE(VectorImageManager, RCTViewManager)
RCT_EXPORT_VIEW_PROPERTY(params, NSArray)
@end
