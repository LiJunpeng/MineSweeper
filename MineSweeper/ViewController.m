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

UIButton *start_button;
UIButton *cheat_button;

NSMutableArray *button_array;
NSMutableArray *mine_array;
NSMutableArray *status_array;
NSArray *tile_icons;

//NSInteger mine_marked;
NSInteger rows;
NSInteger cols;
NSInteger mines;
BOOL cheat_mode;  // need?
NSInteger game_status;  // 0 - not in gmae, 1 - in game,


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    tile_icons = @[[UIImage imageNamed: @"0.png"], [UIImage imageNamed: @"1.png"],[UIImage imageNamed: @"2.png"],[UIImage imageNamed: @"3.png"],[UIImage imageNamed: @"4.png"],[UIImage imageNamed: @"5.png"],[UIImage imageNamed: @"6.png"],[UIImage imageNamed: @"7.png"],[UIImage imageNamed: @"8.png"],[UIImage imageNamed: @"unopen.png"],[UIImage imageNamed: @"question.png"],[UIImage imageNamed: @"flag.png"],[UIImage imageNamed: @"mine.png"],[UIImage imageNamed: @"failed_flag.png"],[UIImage imageNamed: @"explode.png"]];
    
    
    UIButton *cheat_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [cheat_button setTitle: @"Cheat?" forState: UIControlStateNormal];
    [cheat_button.layer setBorderWidth:1.0];
    cheat_button.bounds = CGRectMake(0, 0, 100, 30);
    cheat_button.center = CGPointMake(320.0 * 2 / 3, 40);
    cheat_button.tag = -2;
    [cheat_button addTarget:self action:@selector(cheatButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cheat_button];
    
    
    UIButton *start_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [start_button setTitle: @"Start" forState: UIControlStateNormal];
    [start_button.layer setBorderWidth:1.0];
    start_button.bounds = CGRectMake(0, 0, 100, 30);
    start_button.center = CGPointMake(320.0 * 1 / 3, 40);
    start_button.tag = -2;
    [start_button addTarget:self action:@selector(startGame:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:start_button];
    
}

- (void) initGame {
    
    [self generateBoard];
    cheat_mode = false;
    
}


- (void) generateBoard {
    
    rows = 8;
    cols = 8;
    mines = 8;

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
        //NSLog(@"%d", [[mine_array objectAtIndex:random_number] intValue]);
        count++;
    }
    
}


- (UIButton*) generateTile: (NSInteger) tag_number withX: (NSInteger) x withY: (NSInteger) y {
    
        UIButton *tile = [UIButton buttonWithType:UIButtonTypeCustom];
        //[tile setTitle: [NSString stringWithFormat:@"%d", tag_number] forState: UIControlStateNormal];
        [tile setTitle: @"" forState: UIControlStateNormal];
        [tile setBackgroundImage:tile_icons[9] forState:UIControlStateNormal];
        [tile.layer setBorderWidth:1.0];
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

- (void) checkForWin {
    int count = 0;
    int question_marked = 0;
    int mine_marked = 0;
    for(int i = 1; i <= rows * cols; i++) {
        int tile_status = [[status_array objectAtIndex:i] intValue];
        int tile_has_mine = [[mine_array objectAtIndex:i] intValue];
        
       // NSLog(@"status: %d and mine: %d", tile_status, tile_has_mine);
        
        if(tile_status == 11 && tile_has_mine == 0) {  // marked empty tile, not win
            return;
        }
        
        if(tile_status == 9 || tile_status == 10 || tile_status == 11) { // count unopened tiles
            count++;
            if(tile_status == 11 && tile_has_mine == 1) {
                mine_marked++;
            } else if (tile_status == 10) {
                question_marked++;
            }
        }
        
//        UIButton *button = [button_array objectAtIndex:i];
//        NSInteger status = [[status_array objectAtIndex:i] intValue];
//        [button setBackgroundImage:tile_icons[status] forState:UIControlStateNormal];
    }
    
    NSLog(@"%d and marked: %d", count, mine_marked);
    
    if(count == mines || (mine_marked == mines && question_marked == 0)) { // if unopenned tiles or marked mine == mines, win
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You win!"
                                                        message:@"Easy!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        game_status = 0;
    }
    
}

- (int) countSurroundMines: (int) tile{
    
    int count = 0;
    int total_tiles = cols * rows;
    
    int top_left = tile - cols - 1;
    if(top_left > 0 && top_left % cols != 0 && [[mine_array objectAtIndex: top_left] intValue] == 1) count++;
    
    int top = tile - cols;
    if(top > 0 && [[mine_array objectAtIndex: top] intValue] == 1) count++;
    
    int top_right = tile - cols + 1;
    if(top_right > 0 && top_right % cols != 1 && [[mine_array objectAtIndex: top_right] intValue] == 1) count++;
    
    int left = tile - 1;
    if(left > 0 && left % cols != 0 && [[mine_array objectAtIndex: left] intValue] == 1) count++;
    
    int right = tile + 1;
    if(right <= total_tiles && right % cols != 1 && [[mine_array objectAtIndex: right] intValue] == 1) count++;
    
    int bottom_left = tile + cols - 1;
    if(bottom_left <= total_tiles && bottom_left % cols != 0 && [[mine_array objectAtIndex: bottom_left] intValue] == 1) count++;
    
    int bottom = tile + cols;
    if(bottom <= total_tiles && [[mine_array objectAtIndex: bottom] intValue] == 1) count++;
    
    int bottom_right = tile + cols + 1;
    if(bottom_right <= total_tiles && bottom_right % cols != 1 && [[mine_array objectAtIndex: bottom_right] intValue] == 1) count++;
    
    return count;
}

- (void) blowUp:(int) blow_mine {
    game_status = 0;
    
    for(int i = 1; i <= rows * cols; i++) {
        int tile_status = [[status_array objectAtIndex:i] intValue];
        int tile_has_mine = [[mine_array objectAtIndex:i] intValue];
        
        if(i == blow_mine) {
            [status_array replaceObjectAtIndex: blow_mine withObject: [NSNumber numberWithInt:14]];
            continue;
        }
        
        if(tile_status == 11 && tile_has_mine == 0) {
            [status_array replaceObjectAtIndex: i withObject: [NSNumber numberWithInt:13]];
            continue;
        }
        
        if(tile_status != 11 && tile_has_mine == 1) {
            [status_array replaceObjectAtIndex: i withObject: [NSNumber numberWithInt:12]];
            continue;
        }
    }
    
    [self updateBoardUI];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Boooooom!!!"
                                                    message:@"爆炸吧，现充！！！"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


- (void)longPress:(UILongPressGestureRecognizer*)gesture {
    if(game_status == 1 && !cheat_mode) {
        if (gesture.state == UIGestureRecognizerStateBegan) {
            UIButton *button = (UIButton *)gesture.view;   // get button object
            NSInteger status = [[status_array objectAtIndex: button.tag] intValue];  // get button status
            //NSLog(@"%d", status);
            if(status == 9) { // mark flag
                [status_array replaceObjectAtIndex:button.tag withObject: [NSNumber numberWithInt: 11]];
                
//                if([[mine_array objectAtIndex: button.tag] intValue] == 1) {
//                    mine_marked++;
//                   //NSLog(@"%d", mine_marked);
//                }
                
            } else if(status == 11) {  // mark question mark
                [status_array replaceObjectAtIndex:button.tag withObject: [NSNumber numberWithInt: 10]];
//                if([[mine_array objectAtIndex: button.tag] intValue] == 1) {
//                    mine_marked--;
//                    //NSLog(@"%d", mine_marked);
//                }
            } else if(status == 10) {  // claer mark
                [status_array replaceObjectAtIndex:button.tag withObject: [NSNumber numberWithInt: 9]];
            }
            
            [self checkForWin];
            [self updateBoardUI];
            //[button setBackgroundImage:tile_icons[1] forState:UIControlStateNormal];
        }
    }
}

- (void)singleTap:(UILongPressGestureRecognizer*)gesture {
    UIButton *tile = (UIButton *)gesture.view;
    NSLog(@"%ld", (long)tile.tag);
    if(game_status == 1 && !cheat_mode) {
        if([[status_array objectAtIndex: tile.tag] intValue] == 9) {
            if([[mine_array objectAtIndex: tile.tag] intValue] == 0) {
                
                [self open: tile];
                [self updateBoardUI];
//                int mine_count = [self countSurroundMines:tile.tag];
//                [tile setBackgroundImage: tile_icons[mine_count] forState:UIControlStateNormal];
//                [status_array replaceObjectAtIndex:tile.tag withObject: [NSNumber numberWithInt: mine_count]];
                
                [self checkForWin];
            } else {
                [self blowUp: tile.tag];
            }
        }
        
        
    }
    
    else {NSLog(@"%d", tile.tag);}//[self countSurroundMines:tile]);}
}

- (void) open: (UIButton*) root {
    int mine_count = [self countSurroundMines: root.tag];
    NSLog(@"%d",root.tag);
    [status_array replaceObjectAtIndex:root.tag withObject: [NSNumber numberWithInt: mine_count]];
    if(mine_count == 0) {
        
        int total_tiles = cols * rows;
    
        
        int top = root.tag - cols;
        if(top > 0 && [[status_array objectAtIndex: top] intValue] == 9) [self open: [button_array objectAtIndex: top]];
    
        int left = root.tag - 1;
        if(left > 0 && left % cols != 0 && [[status_array objectAtIndex: left] intValue] == 9) [self open: [button_array objectAtIndex: left]];

        int right = root.tag + 1;
        if(right <= total_tiles && right % cols != 1 && [[status_array objectAtIndex: right] intValue] == 9) [self open: [button_array objectAtIndex: right]];

        int bottom = root.tag + cols;
        if(bottom <= total_tiles && [[status_array objectAtIndex: bottom] intValue] == 9) [self open: [button_array objectAtIndex: bottom]];

    }

}

- (void) cheatButtonPushed:(UIButton *)button {
    if(game_status == 1) {
        cheat_mode = !cheat_mode;
        if(cheat_mode) {
            [button setTitle: @"Stop Cheat" forState: UIControlStateNormal];
        } else {
            [button setTitle: @"Cheat?" forState: UIControlStateNormal];
        }
        [self toggleCheatMode];
    }
}

- (void) toggleCheatMode{
    if(cheat_mode) {
        [self revealBoard];
    } else {
        [self updateBoardUI];
    }
}

- (void) startGame:(UIButton *)button {
    if(game_status == 0) {
        game_status = 1;
        [self initGame];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
