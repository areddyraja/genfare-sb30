//
//  OnboardingViewController.m
//  CDTATicketing
//
//  Created by Andrey Kasatkin on 3/22/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "OnboardingViewController.h"
#import "OnboardingLoginView.h"
#import "StoredData.h"
#import "UIColor+HexString.h"
#import "Utilities.h"

static NSString *const NEW_CARD_NOTIFICATION = @"NewCardNotification";

@implementation OnboardingViewController{
    CGFloat fullWidth;
    CGFloat fullHeight;
    iCarousel *carousel;
    BOOL scrolling;
}

const int TOTAL_PAGES = 3;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    fullWidth = screenRect.size.width;
    fullHeight = screenRect.size.height;
    //1
    //self.scrollView.frame = CGRectMake(0, 0, fullWidth, fullHeight);
    
    //Background for slides
    UIColor *color1 = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities pagerStripBgColor]]];
    UIColor *color2 = [UIColor colorWithHexString:[Utilities colorHexStringFromId:@"bonus_activated_bg"]];
    UIColor *color3 = [UIColor colorWithHexString:[Utilities colorHexStringFromId:@"primary"]];
    UIImageView *imgOne = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,fullWidth, fullHeight)];
    imgOne.image = [self imageWithColor:color1];
    
    imgOne.contentMode = UIViewContentModeScaleToFill;
    UIImageView *imgTwo = [[UIImageView alloc] initWithFrame:CGRectMake(fullWidth, 0,fullWidth, fullHeight)];
    imgTwo.image =[self imageWithColor:color2];
    UIImageView *imgThree = [[UIImageView alloc] initWithFrame:CGRectMake(fullWidth*2, 0,fullWidth, fullHeight)];
    imgThree.image =[self imageWithColor:color3];
    
    [self.scrollView addSubview:imgOne];
    [self.scrollView addSubview:imgTwo];
    [self.scrollView addSubview:imgThree];
    
    //add firstLoginPage
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OnboardingLogin" owner:self options:nil];
    OnboardingLoginView *view = [[OnboardingLoginView alloc] init];
    view = (OnboardingLoginView *)[nib objectAtIndex:0];
    view.frame = CGRectMake(0, 0,fullWidth, fullHeight);
    [self.scrollView addSubview:view];

    
    //4
    self.scrollView.contentSize = CGSizeMake(fullWidth * TOTAL_PAGES, fullHeight);
    self.scrollView.delegate = self;
    self.pageControl.currentPage = 0;
    
    [self setupLoginPage];
    scrolling = NO;
}

- (void)moveToNextPage:(id)sender {
    float pageWidth = fullWidth;
    float maxWidth = pageWidth * TOTAL_PAGES;
    float contentOffset = self.scrollView.contentOffset.x;
    
    float slideToX = contentOffset + pageWidth;
    
    if  (contentOffset + pageWidth == maxWidth){
        slideToX = 0;
    }
    [self.scrollView scrollRectToVisible:CGRectMake(slideToX, 0, pageWidth, CGRectGetHeight(self.scrollView.frame)) animated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    // self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Scroll View Delegate
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    scrolling = NO;
    [self updateCurrentPage];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
     // [self updateCurrentPage];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    /*if (!scrolling){
        [self updateCurrentPage];
        scrolling = YES;*/
  //  }
}

-(void) updateCurrentPage {
    // Test the offset and calculate the current page after scrolling ends
    float pageWidth = fullWidth;
    NSInteger currentPage = floor((self.scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1;
    self.pageControl.currentPage = currentPage;
    
    if (currentPage == 0){
        
    }else if (currentPage == 1){
        [self setupAddCardPage];
    }else if (currentPage == 2){
        [self setupAddTicketsPage];
    }
}


-(void)setupLoginPage{
    [self.addCardButton setTitle:@"Skip Login" forState:UIControlStateNormal];
    self.headerLabel.text = @"Login Or Register";
    self.textView.text = @"Registering an account provides enhanced functionality when it comes to passes. Registered users can transfer cards and passes between any of their mobile devices, so they can purchase a pass on their tablet at home and use the pass on their phone at the station.";
    
    UserData *userData = [StoredData userData];
    if ([userData isLoggedIn]) {
        [self moveToNextPage:nil];
    }
}

-(void)setupAddCardPage{
    [self.addCardButton setTitle:@"Add This Card" forState:UIControlStateNormal];
    self.headerLabel.text = @"Add New Card";
    self.textView.text = @"Your Navigator app is like having a wallet of Navigator smartcards on your phone. Before you can activate passes, you must first create a new Navigator card in which to store your passes.\n\nSelect a card below by swiping left and right (if applicable). Certain cards are only available to pre-qualified users.";
    carousel = [[iCarousel alloc] initWithFrame:self.middleView.bounds];
    [self setupCarousel];
    [self.middleView addSubview:carousel];
    
}


-(void)setupAddTicketsPage{
    [self.addCardButton setTitle:@"Purchase" forState:UIControlStateNormal];
    self.headerLabel.text = @"Add Passes";
    self.textView.text = @"Please name your Navigator mobile card so you can purchase and use a Frequent Rider pass or Pay as You Go value.\n\nTo begin using your new card, go to Purchase Passes, add passes to your Navigator card, and activate your passes from the My Passes section of your app.";
    [carousel removeFromSuperview];

    //add passes image
    UIImage *image = [UIImage imageNamed:@"passes.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = self.middleView.bounds;
    [self.middleView addSubview:imageView];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
- (IBAction)skipClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)addCardClicked:(id)sender {
    if (self.pageControl.currentPage == TOTAL_PAGES - 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    if (self.pageControl.currentPage == 1) {
        if (carousel.currentItemIndex == 0){
            /*RequestNewCardService *newCardService = [[RequestNewCardService alloc] initWithListener:self nickname:cardName description:cardDescription managedObjectContext:self.managedObjectContext uuid:[Utilities deviceId] personId:[StoredData userData].accountId];
             //        [[RequestNewCardService alloc] initWithListener:self nickname:cardName description:cardDescription managedObjectContext:self.managedObjectContext];
             [newCardService execute];*/
        }else
            [self moveToNextPage:sender];

    } else
        [self moveToNextPage:sender];
}


- (UIImage *)imageWithColor:(UIColor*)color{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  img;
}

#pragma mark iCarousel methods

- (void)setupCarousel{
    carousel.dataSource = self;
    carousel.delegate = self;
    carousel.type = iCarouselTypeCoverFlow2;
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 1;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 200.0f)];
        if (index == 0)
//            ((UIImageView *)view).image = [UIImage imageNamed:@"card.png"];
        ((UIImageView *)view).image = [UIImage imageNamed:@"pass.png"];
        else if (index == 1)
            ((UIImageView *)view).image = [UIImage imageNamed:@"card_student.png"];
        else if (index == 2)
            ((UIImageView *)view).image = [UIImage imageNamed:@"card_disable.png"];
        view.contentMode = UIViewContentModeScaleAspectFit;// UIViewContentModeCenter;
        
        /*CGRect labelFrame = CGRectMake(0, 60.0, 60.0, 20.0);
         label = [[UILabel alloc] initWithFrame:labelFrame];
         label.backgroundColor = [UIColor clearColor];
         label.textAlignment = NSTextAlignmentCenter;
         label.font = [label.font fontWithSize:10];
         label.textColor = [UIColor whiteColor];
         label.tag = 1;
         [view addSubview:label];*/
       
    }
    else
    {
        //get a reference to the label in the recycled view
        //label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    if (index == 0) {
        label.text = @"Guest Card";
    } else {
        label.text = @"John's Card";
    }
    
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    
    if (option == iCarouselOptionSpacing)
    {
        return value * 2.3;
    }
    if (option == iCarouselOptionTilt) {
        return 0.7;//default was 0.9
    }
    return value;
}

#pragma mark iCarousel taps

- (void)carousel:(__unused iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"Tapped view number: %lu",(unsigned long) index);
}

- (void)carouselCurrentItemIndexDidChange:(__unused iCarousel *)carousel
{
    NSLog(@"Index: %@", @(carousel.currentItemIndex));
}

#pragma mark - Background service declaration and callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    if ([service isMemberOfClass:[RequestNewCardService class]]) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:NEW_CARD_NOTIFICATION
         object:self];
        [self moveToNextPage:nil];
    }
    
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    if ([service isMemberOfClass:[RequestNewCardService class]]) {
        NSLog(@"couldn't add new card");
    }
}

@end
