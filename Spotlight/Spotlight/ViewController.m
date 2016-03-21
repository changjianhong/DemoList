//
//  ViewController.m
//  Spotlight
//
//  Created by changjianhong on 16/2/7.
//  Copyright © 2016年 changjianhong. All rights reserved.
//

#import "ViewController.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  [self setupSpotlight];
}

- (void)setupSpotlight
{
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    @try {
      NSArray * teachers = @[@"杜超伟",@"东方老师",@"王茹静"];
      NSMutableArray * searchableItems = [NSMutableArray arrayWithCapacity:teachers.count];
      [teachers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CSSearchableItemAttributeSet * attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeImage];
        attributeSet.title = obj;
        attributeSet.contentDescription = obj;
        attributeSet.thumbnailData = UIImagePNGRepresentation([UIImage imageNamed:@"ic_share_logo_pic.jpg"]);
        CSSearchableItem * item = [[CSSearchableItem alloc] initWithUniqueIdentifier:[NSString stringWithFormat:@"%ld",idx + 1] domainIdentifier:@"xiaodiao" attributeSet:attributeSet];
        [searchableItems addObject:item];
      }];
      
      [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:searchableItems completionHandler:^(NSError * _Nullable error) {
        if (!error) {
          NSLog(@"%s, %@", __FUNCTION__, [error localizedDescription]);
        }
      }];
    }
    @catch (NSException *exception) {
      NSLog(@"%s, %@", __FUNCTION__, exception);
    }
    @finally {
      
    }
  });
}
@end
