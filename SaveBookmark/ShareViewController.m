//
//  ShareViewController.m
//  SaveBookmark
//
//  Created by Louis Tur on 1/19/15.
//  Copyright (c) 2015 com.SRLabs. All rights reserved.
//

//to access UTType examples, I need to import this
#import <MobileCoreServices/MobileCoreServices.h>
#import "ShareViewController.h"
#import "ViewController.h"

@interface ShareViewController ()

@property (strong, nonatomic) NSArray * typeIdentifiers;
@property (strong, nonatomic) NSURL * urlToBookmark;

@end

@implementation ShareViewController

-(void)viewDidLoad{
    NSLog(@"View did load");
    
    UIView * testView = [[UIView alloc] initWithFrame:CGRectFromString(@"{{10,10},{40,40}}")];
    [testView setBackgroundColor:[UIColor redColor]];
    
    //[self.view addSubview:testView];
    
    
}
-(void)presentationAnimationDidFinish{
    //used instead of viewWillAppear or viewDidAppear
}

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    
    /**********************************************************************************
     *
     *  Firstly, isContentValid is a method that gets automatically calledor because it is
     *  working with extensions... 
     *
     *  Anyhow, you're suppose to validate the content received from the host application
     *  here before you do anything further with it. 
     *      - Note: Part of this process involves setting the correct dictionary keys
     *              in the info.plist of this extension (see Extensions guides)
     *  For my purposes, I'll use this like I would viewDidLoad:
     *
     *  So as far as flow goes:
     *      1. Host app has it's "share" button pressed, which makes it call a method
     *          that handles Share Extensions loading
     *      2. When an extension is selected, the host app sends the extension an 
     *          NSExtensionContext object that contains information regarding the host
     *          app's extension context.
     *      3. In that context, will be an array of NSExtensionItems representing aspects
     *          of an item for an extension to act upon
     *      4. Each NSExtensionItem contains an array of attachments
     *          - The count and type is determined by your info.plist, at least in part
     *   
     *  When we enter the isContentValid method, I loop through the NSExtensionContext's 
     *  inputItems property (an array) to access its collection of NSExtensionItems. Then
     *  I go through each NSExtensionItem and check its attachments array for NSItemProviders
     *  that are abstracted data objects that are represented by UTI values.
     *
     *  I check each provider to see if it has an item that conforms to kUTTypeURL
     *      - You need to import MobileCoreServices to access the UTType structs and enums
     *      - the kUTTypeURL is of type CFStringRef, meaning you have to prefix it's calls
     *          with (__bridge NSString *) to be able to pass it as a string to a method
     *      - The UTI just defines its type, so UTTypeURL is represented as public.url
     *
     *  To actually do anything with the NSItemProvider, you call the loadItemForType: method
     *  and then implement a completion block to handle the item itself. 
     *      - in this case, the 'item' is an NSURL so my completion block just saves it to 
     *          an instance variable
     *
     *
     ***********************************************************************************/
    
    NSLog(@"Validating content:");
    
    NSItemProviderCompletionHandler bookmarkLocatedHandler = ^(id<NSSecureCoding> item, NSError * error){
        
        if (!error) {
            self.urlToBookmark = (NSURL *)item;
        }
        else{
            NSLog(@"Error encountered in NSItemProviderCompletionHandler: %@", error);
        }
        
    };
    
    
    NSExtensionContext * myContext = self.extensionContext;
    NSArray * myContextualItems = myContext.inputItems;
    
    for (NSExtensionItem * item in myContextualItems)
    {
        for (NSItemProvider * provider in item.attachments)
        {
            if ([provider hasItemConformingToTypeIdentifier:(__bridge NSString *)kUTTypeURL])
            {
                [provider loadItemForTypeIdentifier:(__bridge NSString *)kUTTypeURL
                                            options:nil
                                  completionHandler:bookmarkLocatedHandler];
            }
        }
    }

    return YES;
}

-(void)didSelectCancel{
    
    
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    NSUserDefaults * tubulrDefault = [[NSUserDefaults alloc] initWithSuiteName:kTubulrDomain];
    
    [tubulrDefault setURL:self.urlToBookmark forKey:self.urlToBookmark.absoluteString];
    if ([tubulrDefault synchronize])
    {
        NSLog(@"bookmark saved");
    }else{
        NSLog(@"bookmark not saved");
    }
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
