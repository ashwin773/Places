//
//  DashBoard.m
//  Important functions
//
//  Created by developer9  on 10/29/15.
//  Copyright (c) 2015 developer9 . All rights reserved.
//

#import "DashBoard.h"
#import "ViewController.h"


@implementation DashBoard{
    
       
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
}


-(void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    

}


-(void)viewWillDisappear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
    

    
    
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

- (IBAction)BankBtn:(id)sender {
    ViewController *bank=(ViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerIdentifier"];
    
    bank.type=@"bank";
    [self.navigationController pushViewController:bank animated:YES];

}

- (IBAction)HospitalBtn:(id)sender {
    
    
    ViewController *hospital=(ViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerIdentifier"];
    
     hospital.type=@"hospital";
    [self.navigationController pushViewController:hospital animated:YES];
    
}

- (IBAction)AtmBtn:(id)sender {
    ViewController *atm=(ViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerIdentifier"];
    
    atm.type=@"atm";
    [self.navigationController pushViewController:atm animated:YES];

}

- (IBAction)PoliceBtn:(id)sender {
    ViewController *police=(ViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerIdentifier"];
    
    police.type=@"police";
    [self.navigationController pushViewController:police animated:YES];
    
}

- (IBAction)PetrolBtn:(id)sender {
    
    ViewController *gas_station=(ViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerIdentifier"];
    
    gas_station.type=@"gas_station";
    [self.navigationController pushViewController:gas_station animated:YES];
}

- (IBAction)FireBtn:(id)sender {
    
    ViewController *fire_station=(ViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerIdentifier"];
    
    fire_station.type=@"fire_station";
    [self.navigationController pushViewController:fire_station animated:YES];
}

- (IBAction)resturant:(UIButton *)sender {
    ViewController *resturant=(ViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerIdentifier"];
    
    resturant.type=@"restaurant";
    [self.navigationController pushViewController:resturant animated:YES];
}

- (IBAction)gym:(UIButton *)sender {
    ViewController *gym=(ViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerIdentifier"];
    
    gym.type=@"gym";
    [self.navigationController pushViewController:gym animated:YES];
}

- (IBAction)hardwareStore:(UIButton *)sender {
    ViewController *hardwareStore=(ViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerIdentifier"];
    
    hardwareStore.type=@"hardware_store";
    [self.navigationController pushViewController:hardwareStore animated:YES];
}

- (IBAction)travelAgency:(UIButton *)sender {
    ViewController *travel_agency=(ViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerIdentifier"];
    
    travel_agency.type=@"travel_agency";
    [self.navigationController pushViewController:travel_agency animated:YES];
}



@end
