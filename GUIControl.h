//
//  GUIControl.h
//  ChromeRAM
//
//  Created by Nicolas Sabatier on 30/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GUIControl : NSObject
{
    IBOutlet NSTextView *maTV;
}

-(IBAction)afficher:(id)sender;

@end
