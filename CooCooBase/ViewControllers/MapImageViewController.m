//
//  MapImageViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 8/26/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "MapImageViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Utilities.h"

@interface MapImageViewController ()

@end

@implementation MapImageViewController
{
    UIImageView *imageView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:[Utilities stringResourceForId:@"transit_map"]];
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Maps" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    
    [self showProgressDialog];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [imageView setUserInteractionEnabled:YES];
    
    __block MapImageViewController *blockSafeSelf = self;
    __block UIImageView *blockSafeImageView = imageView;
    
    if (!self.isLocal) {
        NSString *imageUrlString;
        imageUrlString = [NSString stringWithFormat:self.mapFile, [Utilities apiUrl]];
        [imageView setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imageUrlString]]
                         placeholderImage:nil
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      CGFloat scaleX = blockSafeImageView.bounds.size.width / image.size.width;
                                      CGFloat scaleY = blockSafeImageView.bounds.size.height / image.size.height;
                                      CGFloat scale = MIN(scaleX, scaleY);
                                      
                                      [blockSafeImageView setFrame:CGRectMake(0, 0, image.size.width * scale, image.size.height * scale)];
                                      [blockSafeImageView setImage:image];
                                      
                                      [blockSafeSelf dismissProgressDialog];
                                  }
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      [blockSafeSelf dismissProgressDialog];
                                  }
         ];
        
    } else {
        [imageView setImage:[UIImage loadOverrideImageNamed:self.mapFile]];
    }
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
    [panRecognizer setDelegate:self];
    [self.view addGestureRecognizer:panRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchDetected:)];
    [pinchRecognizer setDelegate:self];
    [self.view addGestureRecognizer:pinchRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    tapRecognizer.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapRecognizer];
    
    [self.view addSubview:imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - View controls

- (void)panDetected:(UIPanGestureRecognizer *)panRecognizer
{
    CGPoint translation = [panRecognizer translationInView:self.view];
    CGPoint imageViewPosition = imageView.center;
    imageViewPosition.x += translation.x;
    imageViewPosition.y += translation.y;
    
    [imageView setCenter:imageViewPosition];
    [panRecognizer setTranslation:CGPointZero inView:self.view];
}

- (void)pinchDetected:(UIPinchGestureRecognizer *)pinchRecognizer
{
    CGFloat scale = pinchRecognizer.scale;
    [imageView setTransform:CGAffineTransformScale(imageView.transform, scale, scale)];
    [pinchRecognizer setScale:1.0];
}

- (void)tapDetected:(UITapGestureRecognizer *)tapRecognizer
{
    [UIView animateWithDuration:0.25 animations:^{
        [imageView setTransform:CGAffineTransformIdentity];
        [imageView setFrame:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    }];
}

@end
