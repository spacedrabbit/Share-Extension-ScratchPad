//
//  ViewController.m
//  FibSequenceExam
//
//  Created by Louis Tur on 1/12/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "ViewController.h"

@interface ViewController () <UIGestureRecognizerDelegate, UIWebViewDelegate, MKMapViewDelegate>

@property (strong, nonatomic) NSUserDefaults * tubulrUserDefaults;
@property (strong, nonatomic) NSDictionary * tubulrPersistentDomain;

@property (strong, nonatomic) CLLocationManager * locationManager;
@property (strong, nonatomic) MKMapView * previewMapView;
@property (strong, nonatomic) UIView * blueBlockView;
@property (nonatomic) CGRect originalFrameRect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //-- NOTIFICATION REGISTERING --//
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(zoomToAnnotation:)
                                                 name:@"mapPoint"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeToNSUserDefaults:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    
    // -- NSUSERDEFAULTS SETUP -- //
    
    // Checking / creating the user defaults for the app
    //NSLog this dict to check current domains
    self.tubulrUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:kTubulrDomain];
    
    
    // -- VIEW SETUP -- //
    
    CFDictionaryRef boundsRectDictionary = CGRectCreateDictionaryRepresentation([UIScreen mainScreen].bounds);
    CGRectMakeWithDictionaryRepresentation(boundsRectDictionary, &_originalFrameRect);
    
    UIButton * saveABookmark = [self makeMeAButton];
    [saveABookmark setFrame:CGRectFromString(@"{{10, 200},{ 100, 50}}")];
    [self.view addSubview:saveABookmark];
    
    UIButton * displayBookmarks = [self makeMeAButton];
    [displayBookmarks setFrame:CGRectFromString(@"{{120, 200},{100, 50}}")];
    [self.view addSubview:displayBookmarks];
    
    [saveABookmark addTarget:self action:@selector(saveBookmarkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [displayBookmarks addTarget:self action:@selector(loadBookmarksButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void) saveBookmarkButtonPressed:(id)sender{
    
    NSString * testString = @"http://google.com/search?=searchingthething";
    [self saveBookmark:testString withLabel:@"Google Search Results"];
    
}
-(void) loadBookmarksButtonPressed:(id)sender{
    
    
    UITextView * listOfBookmarks = [[UITextView alloc] initWithFrame:CGRectFromString(@"{{10, 260 },{300, 200}}")];
    [listOfBookmarks setBackgroundColor:[UIColor yellowColor]];
    [listOfBookmarks setEditable:NO];
    [self.view addSubview:listOfBookmarks];
    
    [self loadBookmarksInView:listOfBookmarks];
    
}

-(void) saveBookmark:(NSString *)bookmarkString withLabel:(NSString *)label {
    
    //[self.tubulrUserDefaults setObject:bookmarkString forKey:label];
    [self.tubulrUserDefaults setValue:bookmarkString forKey:label];
    if ([self.tubulrUserDefaults synchronize]) {
        NSLog(@"Bookmark Saved");
    }else{
        NSLog(@"Unable to save Bookmark");
    }
    
}
-(void) loadBookmarksInView:(UITextView *)view
{
    view.text =[NSString stringWithFormat:@"%@",[self.tubulrUserDefaults dictionaryRepresentation]];
}

-(void) changeToNSUserDefaults:(NSNotification *)notification
{
    NSLog(@"Defaults have changed");
}

-(UIButton *) makeMeAButton{
    
    UIButton * aRandomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];\
    [aRandomButton setBackgroundColor:[UIColor lightGrayColor]];
    [aRandomButton setTitle:@"Press Me" forState:UIControlStateNormal];
    
    return aRandomButton;
}

/**********************************************************************************
 *
 *
 *          OLDER METHODS
 *
 *
 ***********************************************************************************/
-(void)runLocationManager{
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager requestWhenInUseAuthorization];
    
    [self.locationManager startUpdatingLocation];
    
    CGRect testRect = CGRectFromString(@"{{0,200},{200,150}}");
    self.previewMapView = [[MKMapView alloc] initWithFrame:testRect];
    [self.previewMapView setDelegate:self];
    [self.view addSubview:self.previewMapView];
    
    CGRect blueSquareRect = CGRectFromString(@"{{10, 10},{50,50}}");
    
    self.blueBlockView = [[UIView alloc] initWithFrame:blueSquareRect];
    [self.blueBlockView setBackgroundColor:[UIColor blueColor]];
    [self.blueBlockView setUserInteractionEnabled:YES];
    [self.view addSubview:self.blueBlockView];
    
    [self makeAWebView];
    
    UIGestureRecognizer * tapView = [[UITapGestureRecognizer alloc] init];
    [tapView setDelegate:self];
    [tapView setEnabled:YES];
    [tapView addTarget:self action:@selector(makeNotification)];
    [self.blueBlockView addGestureRecognizer:tapView];
}


-(void)zoomToAnnotation:(NSNotification *)notification {
    
    MKMapItem *passedMapItem = (MKMapItem *)notification.object;
    CLLocationCoordinate2D coordinateOfInterest = passedMapItem.placemark.coordinate;
    
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinateOfInterest, MKCoordinateSpanMake(.05, .05));
    [self.previewMapView setRegion:region
                          animated:YES];
    
    [self.previewMapView addAnnotation:passedMapItem.placemark];
    
}

-(void) makeNotification{
    
    [self.locationManager startUpdatingLocation];
    
    CLLocationCoordinate2D coordinateOfInterest = self.locationManager.location.coordinate;
    MKPlacemark * placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinateOfInterest
                                                    addressDictionary:nil];
    
    MKMapItem * mapItem = [[MKMapItem alloc] initWithPlacemark:placeMark];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mapPoint"
                                                        object:mapItem ];
    
}

-(void) makeAWebView{
    
    [[NSOperationQueue currentQueue] addOperationWithBlock:^{
        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 200, 200, 200)];
        myLabel.layer.borderWidth = 3.0;
        myLabel.layer.borderColor = [UIColor redColor].CGColor;
        [myLabel setUserInteractionEnabled:YES];
        
        UIGestureRecognizer * labelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelHasBeenPressed:)];
        [myLabel addGestureRecognizer:labelTapGesture];
        
        UIWebView * smallerLink = [[UIWebView alloc] initWithFrame:CGRectMake(10, 10, 150, 100)];
        [smallerLink setBackgroundColor:[UIColor lightGrayColor]];
        //[myLabel addSubview:smallerLink];

        [smallerLink setDelegate:self];
        [self.view addSubview:myLabel];
        
        if (CGRectContainsRect([smallerLink frame], [myLabel frame])) {
            NSLog(@"Rect contained");
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [smallerLink loadHTMLString:@"<a href=\"http://google.com\">This is a link!</a>" baseURL:[NSURL URLWithString:@""]];
        }];
    }];
    
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if (navigationType == (UIWebViewNavigationTypeLinkClicked|UIWebViewNavigationTypeOther) ) {
        NSLog(@"Navigation Clicked");
        return YES;
    }
    else{
        NSLog(@"Navigation type of: %li", navigationType);
    }
    
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"Did finish load");
}

-(void) fibanacciVerificationForSequence:(NSArray *)numbersArray
                              usingBlock:(void(^)(NSInteger nthValue, NSInteger position, BOOL error))fibBlock{
    
    [numbersArray enumerateObjectsWithOptions:NSEnumerationReverse
                                   usingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        
        
    }];
    
    
}

-(void) fibanacciBlockSequenceFor:(NSInteger)nthElement usingBlock:(void (^)(NSInteger))fibBlock
{
    
    NSInteger calculatedNthValue = [self fibonacciSequenceFor:nthElement];
    fibBlock(calculatedNthValue);
    
}
-(NSInteger) fibonacciSequenceFor:(NSInteger)nthElementInSequence{

    NSInteger nMinus1 = 1, nMinus2 = 0, nthValue = 0;
    NSMutableArray * fibanacciValues = [NSMutableArray new];
    if (nthElementInSequence == 0) {
        return 0;
    }else if ( nthElementInSequence == 1 ){
        return 1;
    }else{
        for(NSInteger i = 1; i < nthElementInSequence; i++){
            
            nthValue = nMinus2 + nMinus1;
            nMinus2 = nMinus1;
            nMinus1 = nthValue;
        }
    }

    return nthValue;
}
-(NSInteger) recursiveFibanacciSequenceFor:(NSInteger) nthElementInSequence{
    
    if (nthElementInSequence == 0) {
        return 0;
    }else if ( nthElementInSequence == 1){
        return 1;
    }else{
        return [self recursiveFibanacciSequenceFor:nthElementInSequence-2] + [self recursiveFibanacciSequenceFor:nthElementInSequence-1];
    }
}

-(void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    
    CFDictionaryRef currentRect = CGRectCreateDictionaryRepresentation(self.blueBlockView.frame);
    
    if (newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ) {
        //landscape
       // CFStringRef widthValue = CFStringCreateWithCString(<#CFAllocatorRef alloc#>, <#const char *cStr#>, <#CFStringEncoding encoding#>);
       // CFNumberRef val = CFDictionaryGetValue(currentRect, (const void *)widthValue);
        
    }else{
        //potrait
        
        
        
    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
