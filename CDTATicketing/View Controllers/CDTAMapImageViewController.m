//
//  CDTAMapImageViewController.m
//  CDTA
//
//  Created by CooCooTech on 10/22/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTAMapImageViewController.h"
#import <AFNetworking/UIKit+AFNetworking.h>
#import "CooCooBase.h"

@interface CDTAMapImageViewController ()

@end

@implementation CDTAMapImageViewController
{
    //LogoBarButtonItem *logoBarButton;
    UIActivityIndicatorView *spinner;
    Map *map;
    UIImageView *imageView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil map:(Map *)m
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        map = m;
        
        [self setViewName:[NSString stringWithFormat:@"%@ Map", map.name]];
        [self setTitle:map.name];
        
        //logoBarButton = [[LogoBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                              0,
                                                              self.view.frame.size.width,
                                                              self.view.frame.size.height)];
    [imageView setUserInteractionEnabled:YES];
    
    if (map.isLocal) {
        UIImage *mapImage = [UIImage imageNamed:map.uri];
        [imageView setImage:mapImage];
        
        CGFloat scaleX = imageView.bounds.size.width / mapImage.size.width;
        CGFloat scaleY = imageView.bounds.size.height / mapImage.size.height;
        CGFloat scale = MIN(scaleX, scaleY);
        
        [imageView setFrame:CGRectMake(0, 0, mapImage.size.width * scale, mapImage.size.height * scale)];
    } else {
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
        [spinner startAnimating];
        
        //__block CDTAMapImageViewController *blockSafeSelf = self;
        //__block LogoBarButtonItem *blockSafeLogoButton = logoBarButton;
        __block UIActivityIndicatorView *blockSafeSpinner = spinner;
        __block UIImageView *blockSafeImageView = imageView;
        
        [imageView setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:map.uri]]
                         placeholderImage:nil
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      CGFloat scaleX = blockSafeImageView.bounds.size.width / image.size.width;
                                      CGFloat scaleY = blockSafeImageView.bounds.size.height / image.size.height;
                                      CGFloat scale = MIN(scaleX, scaleY);
                                      
                                      [blockSafeImageView setFrame:CGRectMake(0, 0, image.size.width * scale, image.size.height * scale)];
                                      [blockSafeImageView setImage:image];
                                      
                                      [blockSafeSpinner stopAnimating];
                                      //[blockSafeSelf.navigationItem setRightBarButtonItem:blockSafeLogoButton];
                                  }
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      [blockSafeSpinner stopAnimating];
                                      //[blockSafeSelf.navigationItem setRightBarButtonItem:blockSafeLogoButton];
                                  }
         ];
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
