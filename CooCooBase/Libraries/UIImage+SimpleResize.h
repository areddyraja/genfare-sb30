//
//  UIImage+SimpleResize.m
//
//  Modified by Robert Ryan on 5/19/11.
//
//  Got the basic idea at http://ofcodeandmen.poltras.com/2008/10/30/undocumented-uiimage-resizing/
//  but had to rewrite to support AspectFill and AspectFit modes.
//
//  By the way, I was enticed by http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/
//  but it turns out that those routines just don't handle some stranger file formats (CMYK, etc.) well
//  because it tries to create a new context that mirrors the one of the image, some of which the
//  CGBitmapContextCreate() just chokes on.
//
//  I'm sure there are richer implementations, but my solution has benefit of being simple, and it works.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (SimpleResize)

- (UIImage *)scaleImageToSizeFill:(CGSize)newSize;
- (UIImage *)scaleImageToSizeAspectFill:(CGSize)newSize;
- (UIImage *)scaleImageToSizeAspectFit:(CGSize)newSize;

@end
