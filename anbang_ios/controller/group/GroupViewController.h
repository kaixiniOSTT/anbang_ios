//
//  GroupViewController.h

#import <UIKit/UIKit.h>


@interface GroupViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
   }
@property(nonatomic,retain)NSMutableArray *groupArray;
@end
