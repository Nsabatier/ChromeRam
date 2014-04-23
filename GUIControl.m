//
//  GUIControl.m
//  ChromeRAM
//
//  Created by Nicolas Sabatier on 30/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GUIControl.h"

@implementation GUIControl

- (id)init
{
    self = [super init];
    if (self) {
       
        // Initialization code here.
    }
    
    return self;
}

-(IBAction)afficher:(id)sender
{
    [maTV setEditable:NO];
    NSTask *task = [[NSTask alloc] init];
    NSArray *arguments;
    NSPipe *pipe = [NSPipe pipe];
	NSPipe *resultPipe = [[NSPipe alloc] init];
    
    //première tache top -l 1 -o rsize -stats command,rsize  
    //affiche nom et taille
    [task setLaunchPath: @"/usr/bin/top"];
    arguments = [NSArray arrayWithObjects: @"-l 1", @"-o",@"rsize",@"-stats",@"command,rsize", nil];
    [task setArguments: arguments];
    [task setStandardOutput: pipe];
    [task launch];
    
    //deuxième tache grep Chrome
	NSTask *task2 = [[NSTask alloc] init];
	[task2 setLaunchPath: @"/usr/bin/grep"];
	[task2 setArguments: [NSArray arrayWithObjects: @"Chrome", nil]];
	[task2 setStandardInput: pipe];//gestion du pipe |
	[task2 setStandardOutput: resultPipe];
	[task2 launch];
    
	NSData *result = [[resultPipe fileHandleForReading] readDataToEndOfFile];
    
    NSString *string;
    string = [[[NSString alloc] initWithData: result encoding: NSUTF8StringEncoding]autorelease];
    
    
    //nombre de lignes
    NSInteger length = [[string componentsSeparatedByCharactersInSet:
                         [NSCharacterSet newlineCharacterSet]] count];
    length-=6;
    
    //Nettoyage du résultat en enlevant les textes pour ne garder que la place en RAM
    string = [string stringByReplacingOccurrencesOfString:@"Google Chrome He" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"Google Chrome" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"ChromeRAM" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSMutableArray *arr = [[string componentsSeparatedByString:@"M+"] mutableCopy];

    //NSLog(@" Contenu %@",arr); %@ string, %ld long, %g double
    
    float val = 0;
    float test = 0;
    //NSLog(@"Nombre de processus : %ld", length);
    for (int i=0; i<length;i++)
    {
        test = [[arr objectAtIndex:i] integerValue];;
        //NSLog(@"Valeur : %f", test);
        val += [[arr objectAtIndex:i] integerValue];;
    }
    
    //afficher avec deux chiffres après la virgule
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.roundingIncrement = [NSNumber numberWithDouble:0.01];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    if (length>1)
    {
        val = val - 15;
        string  = @"Total : ";
        
        if (val<1000)
        {
            string = [string stringByAppendingString:[NSString stringWithFormat:@"%g", (double)val]];
            string = [string stringByAppendingString:@"Mo"];
        }
        else
        {
            val = val/1000;
            NSNumber *numberVal = [NSNumber numberWithDouble:val];
            string = [string stringByAppendingString:[NSString stringWithFormat:@"%@", [formatter stringFromNumber:numberVal]]];
            
            
            string = [string stringByAppendingString:@" Go"];
        }
        
        string = [string stringByAppendingString:@"\nNombre de processus : "];
        string = [string stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)length]];
    }
    else
    {
        length = 0;
        val = 0;
        string  = @"Total : ";
        string = [string stringByAppendingString:[NSString stringWithFormat:@"%g", (double)val]];
        string = [string stringByAppendingString:@"Mo"];
        string = [string stringByAppendingString:@"\nNombre de processus : "];
        string = [string stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)length]];
    }
    
    [maTV setString: string];
        
    [task release];
	[task2 release];
    [arr release];
    // pour récupérer le texte d'une NSTextView     s = [[maTV textStorage] string];
}

@end
