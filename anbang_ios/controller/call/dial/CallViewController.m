//
//  CallViewController.m
//  anbang_ios
//
//  Created by silenceSky  on 14-12-23.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "CallViewController.h"

@interface CallViewController ()

@end

@implementation CallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        //self.edgesForExtendedLayout = UIRectEdgeNone;
        //self.extendedLayoutIncludesOpaqueBars = NO;
        //self.modalPresentationCapturesStatusBarAppearance = YES;
        self.navigationController.navigationBar.translucent = NO;
        //self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    }
    
    
    segmentedControl = [ [ UISegmentedControl alloc ]
                        initWithItems: nil ];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [ segmentedControl insertSegmentWithTitle:
     NSLocalizedString(@"call.call",@"action") atIndex: 0 animated: NO ];
    [ segmentedControl insertSegmentWithTitle:
     NSLocalizedString(@"call.callRecords",@"action") atIndex: 1 animated: NO ];
    [ segmentedControl insertSegmentWithTitle:
     NSLocalizedString(@"call.callContacts",@"action") atIndex: 2 animated: NO ];
    
    [segmentedControl setSelectedSegmentIndex:0];
    
    self.navigationItem.titleView = segmentedControl;
    
    [segmentedControl addTarget:self
                         action: @selector(controllerPressed:)
               forControlEvents: UIControlEventValueChanged
     ];
    
    segmentedControl.tintColor = [UIColor whiteColor];

    NSString *dialXib= @"DialViewController2_ipad";
    
    
    // NSLog(@"*********%i",kIsPad);
    
    if (kIsPad) {
        dialXib = @"DialViewController2_ipad";
        
    }else{
        if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)){
            if (kIsiPhone5) {
                dialXib = @"DialViewController2_ios7";
                
            }else if(kIsiPhone6){
                dialXib = @"DialViewController2_iphone6";
            }else if(kIsiPhone6p){
                dialXib = @"DialViewController2_iphone6plus";
                
            }else{
                dialXib = @"DialViewController2";
                
            }
        }else  {
            dialXib = @"DialViewController2";
        }
    }
    
    dialVC = [[DialViewController2 alloc] initWithNibName:dialXib bundle:nil];
    dialVC.view.tag=10000;
    [self.view addSubview:dialVC.view];
    
    callRecordsVC = [[CallRecordsViewController alloc] init];
    callRecordsVC.view.tag = 10001;
    [self.view addSubview:callRecordsVC.view];
    callRecordsVC.view.hidden = YES;
    
    callContactsVC = [[CallContactsViewController alloc] init];
    callContactsVC.view.tag = 10002;
    [self.view addSubview:callContactsVC.view];
    callContactsVC.view.hidden = YES;
    

}

//分段控制器
- (void)controllerPressed:(id)sender {
    int selectedSegmentIndex = segmentedControl.selectedSegmentIndex;
    
    // NSLog(@"*******%d",selectedSegmentIndex);
    if (selectedSegmentIndex==0) {
 
        callRecordsVC.receiveUserJID = @"";
        [[self.view viewWithTag:10001] setHidden:YES];
        [[self.view viewWithTag:10002] setHidden:YES];

        [[self.view viewWithTag:10000] setHidden:NO];
        
    }else if(selectedSegmentIndex==1){
        
        //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"NNC_Is_Have_Userinfo" object:nil];
            [[self.view viewWithTag:10000] setHidden:YES];
            [[self.view viewWithTag:10002] setHidden:YES];

        [[self.view viewWithTag:10001] setHidden:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
        [callRecordsVC refreshData];
        });
        
    }else if(selectedSegmentIndex==2){
            [[self.view viewWithTag:10001] setHidden:YES];
            [[self.view viewWithTag:10000] setHidden:YES];
    
        [[self.view viewWithTag:10002] setHidden:NO];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
