@class InteractiveImage;

@protocol InteractiveImageDelegate <NSObject>

@optional

- (void) imageDidSelect:(InteractiveImage*)newlySelectedImage;

- (void) imageDidDrag:(InteractiveImage*)draggedImage;
- (void) imageDidDrop:(InteractiveImage*)droppedImage;

- (void) imageDidTap:(InteractiveImage*)tappedImage;
- (void) imageMoved:(InteractiveImage*)movedImage;

@end