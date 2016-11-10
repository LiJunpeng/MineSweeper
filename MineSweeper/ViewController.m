//
//  ViewController.m
//  MineSweeper
//
//  Created by LILouis on 11/9/16.
//  Copyright © 2016 LILouis. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

UIButton *cheat_button;

NSMutableArray *button_array;
NSMutableArray *mine_array;
NSMutableArray *status_array;
NSArray *tile_icons;

NSInteger mine_marked;
NSInteger rows;
NSInteger cols;
NSInteger mines;
BOOL cheat_mode;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    tile_icons = @[[UIImage imageNamed: @"0.png"], [UIImage imageNamed: @"1.png"],[UIImage imageNamed: @"2.png"],[UIImage imageNamed: @"3.png"],[UIImage imageNamed: @"4.png"],[UIImage imageNamed: @"5.png"],[UIImage imageNamed: @"6.png"],[UIImage imageNamed: @"7.png"],[UIImage imageNamed: @"8.png"],[UIImage imageNamed: @"unopen.png"],[UIImage imageNamed: @"question.png"],[UIImage imageNamed: @"flag.png"],[UIImage imageNamed: @"mine.png"],[UIImage imageNamed: @"failed_flag.png"],[UIImage imageNamed: @"explode.png"]];
    
    [self initGame];
    
}

- (void) initGame {
    
    [self generateBoard];
    cheat_mode = false;
    
    UIButton *cheat_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [cheat_button setTitle: @"Cheat?" forState: UIControlStateNormal];
    [cheat_button.layer setBorderWidth:1.0];
    cheat_button.bounds = CGRectMake(0, 0, 140, 30);
    cheat_button.center = CGPointMake(320.0 * 2 / 3, 40);
    cheat_button.tag = -2;
    [cheat_button addTarget:self action:@selector(toggleCheatMode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cheat_button];
    
}


- (void) generateBoard {
    
    rows = 3;
    cols = 3;
    mines = 4;

    button_array = [[NSMutableArray alloc] init];
    [button_array addObject: @"spare"];
    for(int i = 1; i <= rows; i++) {
        for(int j = 1; j <= cols; j++ ) {
            NSInteger tag_number = j + (i - 1) * cols;
            NSInteger x = 40 * j;
            NSInteger y =100 + (i - 1) * 40;
            [button_array addObject: [self generateTile: tag_number withX: x withY: y]];
        }
    }
    
    
//    UIButton *b = mine_board[1];
//    [b setBackgroundImage:tile_icons[8] forState:UIControlStateNormal];
    
    mine_array = [[NSMutableArray alloc] init];
    for(int i = 0; i <= rows * cols; i++) {
        [mine_array addObject: [NSNumber numberWithInt:0]];
        //NSLog(@"%d",[[mine_array objectAtIndex: i]intValue]);
    }
    
    status_array = [[NSMutableArray alloc] init];  //!!!!!!!!!!!!
    for(int i = 0; i <= rows * cols; i++) {
        [status_array addObject: [NSNumber numberWithInt:9]];
        //NSLog(@"%d",[[status_array objectAtIndex: i] intValue]);
    }
    
    NSInteger count = 0;
    while(count < mines) {
        NSInteger random_number = arc4random_uniform(rows * cols - 1) + 1;
        if([[mine_array objectAtIndex: random_number]intValue] == 1) {
            continue;
        }
        [mine_array replaceObjectAtIndex: random_number withObject: [NSNumber numberWithInt:1]];
        count++;
    }
    

}


- (UIButton*) generateTile: (NSInteger) tag_number withX: (NSInteger) x withY: (NSInteger) y {
    
        UIButton *tile = [UIButton buttonWithType:UIButtonTypeCustom];
        //[tile setTitle: [NSString stringWithFormat:@"%d", tag_number] forState: UIControlStateNormal];
        [tile setTitle: @"" forState: UIControlStateNormal];
        [tile setBackgroundImage:tile_icons[9] forState:UIControlStateNormal];
        [tile.layer setBorderWidth:3.0];
        tile.bounds = CGRectMake(0, 0, 40, 40);

        tile.center = CGPointMake(x, y);
        tile.tag = tag_number;
    //NSLog(@"%d",tag_number);
    
        UILongPressGestureRecognizer *long_press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [tile addGestureRecognizer:long_press];
    
        UITapGestureRecognizer *single_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [tile addGestureRecognizer:single_tap];
    
        [self.view addSubview:tile];
    return tile;
}

- (void) revealBoard {
    for(int i = 1; i <= rows * cols; i++) {
        if([[mine_array objectAtIndex:i] intValue] == 1) {
            UIButton *button = [button_array objectAtIndex:i];
            [button setBackgroundImage:tile_icons[12] forState:UIControlStateNormal];
        }
    }
}

//- (void) concealBoard {
//    for(int i = 1; i <= rows * cols; i++) {
//        UIButton *button = [button_array objectAtIndex:i];
//        NSInteger status = [[status_array objectAtIndex:i] intValue];
//        [button setBackgroundImage:tile_icons[status] forState:UIControlStateNormal];
//    }
//}

- (void) updateBoardUI {
    for(int i = 1; i <= rows * cols; i++) {
        UIButton *button = [button_array objectAtIndex:i];
        NSInteger status = [[status_array objectAtIndex:i] intValue];
        [button setBackgroundImage:tile_icons[status] forState:UIControlStateNormal];
    }
}


- (void)longPress:(UILongPressGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UIButton *button = (UIButton *)gesture.view;   // get button object
        NSInteger status = [[status_array objectAtIndex: button.tag] intValue];  // get button status
        NSLog(@"%d", status);
        if(status == 9) {
            [status_array replaceObjectAtIndex:button.tag withObject: [NSNumber numberWithInt: 11]];
        } else if(status == 11) {
            [status_array replaceObjectAtIndex:button.tag withObject: [NSNumber numberWithInt: 10]];
        } else if(status == 10) {
            [status_array replaceObjectAtIndex:button.tag withObject: [NSNumber numberWithInt: 9]];
        }
        
        [self updateBoardUI];
        //[button setBackgroundImage:tile_icons[1] forState:UIControlStateNormal];
    }
}

- (void)singleTap:(UILongPressGestureRecognizer*)gesture {
    UIButton *tile = (UIButton *)gesture.view;
    NSLog(@"%ld", (long)tile.tag);

}

- (void) toggleCheatMode:(UIButton *)button {
    
    if(cheat_mode) {
        [button setTitle: @"Play" forState: UIControlStateNormal];
        [self revealBoard];
    } else {
        [button setTitle: @"Cheat?" forState: UIControlStateNormal];
        //[self concealBoard];
        [self updateBoardUI];
    }
    cheat_mode = !cheat_mode;
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
