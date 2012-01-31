////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.components
{

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.FocusEvent;

import mx.events.FlexEvent;
import mx.managers.IFocusManagerComponent;

include "../styles/metadata/AdvancedCharacterFormatTextStyles.as"
include "../styles/metadata/AdvancedContainerFormatTextStyles.as"
include "../styles/metadata/AdvancedParagraphFormatTextStyles.as"
include "../styles/metadata/BasicCharacterFormatTextStyles.as"
include "../styles/metadata/BasicContainerFormatTextStyles.as"
include "../styles/metadata/BasicParagraphFormatTextStyles.as"
include "../styles/metadata/SelectionFormatTextStyles.as"

/**
 *  @copy mx.components.baseClasses.GroupBase#contentBackgroundColor
 */
[Style(name="contentBackgroundColor", type="uint", format="Color", inherit="yes")]


[IconFile("FxNumericStepper.png")]
/**
 *  The FxNumericStepper control lets you select
 *  a number from an ordered set.
 *  The FxNumericStepper provides the same functionality as
 *  the FxSpinner component, but adds a TextInput control
 *  so that you can directly edit the value of the component,
 *  rather than modifying it by using the control's arrow buttons.
 *
 *  <p>The FxNumericStepper control consists of a single-line
 *  input text field and a pair of arrow buttons
 *  for stepping through the possible values.
 *  The Up Arrow and Down Arrow keys also cycle through 
 *  the values. 
 *  An input value is committed when
 *  the user presses the Enter key, removes focus from the
 *  component, or steps the FxNumericStepper by pressing an arrow button
 *  or by calling the <code>step()</code> method.</p>
 *
 *  @see mx.components.FxSpinner
 * 
 *  @includeExample examples/FxNumericStepperExample.mxml
 */
public class FxNumericStepper extends FxSpinner implements IFocusManagerComponent
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor
     */  
    public function FxNumericStepper()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  SkinParts
    //
    //--------------------------------------------------------------------------

    [SkinPart(required="true")]
    
    /**
     *  A skin part that defines a TextInput control 
     *  which allows a user to edit the value of
     *  the FxNumericStepper component. 
     *  The value is rounded and committed
     *  when the user presses enter, focuses out of
     *  the FxNumericStepper, or steps the FxNumericStepper.
     */
    public var textInput:FxTextInput;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  maxChars
    //----------------------------------

    /**
     *  @private
     *  Storage for the maxChars property.
     */
    private var _maxChars:int = 0;

    /**
     *  @private
     */
    private var maxCharsChanged:Boolean = false;

    /**
     *  The maximum number of characters that can be entered in the field.
     *  A value of 0 means that any number of characters can be entered.
     *
     *  @default 0
     */
    public function get maxChars():int
    {
        return _maxChars;
    }

    /**
     *  @private
     */
    public function set maxChars(value:int):void
    {
        if (value == _maxChars)
            return;
            
        _maxChars = value;
        maxCharsChanged = true;
        
        invalidateProperties();
    }
    
    //--------------------------------- 
    // displayFormatFunction
    //---------------------------------

    private var _displayFormatFunction:Function;
    private var displayFormatFunctionChanged:Boolean;
    
     /**
     *  Callback function that formats the value displayed
     *  in the textInput field.
     *  The function takes a single Number as an argument
     *  and returns a formatted String.
     *
     *  <p>The function has the following signature:</p>
     *  <pre>
     *  funcName(value:Number):String
     *  </pre>
     
     *  @default undefined   
     */
    public function get displayFormatFunction():Function
    {
        return _displayFormatFunction;
    }
    
    /**
     *  @private
     */
    public function set displayFormatFunction(value:Function):void
    {
        _displayFormatFunction = value;
        
        displayFormatFunctionChanged = true;
        
        invalidateProperties();
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  baselinePosition
    //----------------------------------

    /**
     *  @private
     */
    override public function get baselinePosition():Number
    {
        return getBaselinePositionForPart(textInput);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Properties: FxRange
    //
    //--------------------------------------------------------------------------
    
    //---------------------------------
    // maximum
    //---------------------------------   
    
    private var _maximum:Number = 10;
    private var maxChanged:Boolean = false;
    
    /**
     *  Number which represents the maximum value possible for 
     *  <code>value</code>. If the values for either 
     *  <code>minimum</code> or <code>value</code> are greater
     *  than <code>maximum</code>, they will be changed to 
     *  reflect the new <code>maximum</code>
     *
     *  @default 10
     */
    override public function get maximum():Number
    {
        return _maximum;
    }
    
    override public function set maximum(value:Number):void
    {
        if (value == _maximum)
            return;

        _maximum = value;
        maxChanged = true;

        invalidateProperties();
    }
    
    //---------------------------------
    // stepSize
    //---------------------------------   
    
    private var stepSizeChanged:Boolean = false;
    
    /**
     *  @private
     */
    override public function set stepSize(value:Number):void
    {
        stepSizeChanged = true;
        super.stepSize = value;       
    }   
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function commitProperties():void
    {	
        super.commitProperties();
		
		if (maxChanged || stepSizeChanged || displayFormatFunctionChanged)
    	{
    		textInput.widthInChars = calculateWidestValue();
    		maxChanged = false;
    		stepSizeChanged = false;
    		
    		if (displayFormatFunctionChanged)
    		{
                applyDisplayFormatFunction();
               
                displayFormatFunctionChanged = false;
    		}
    	}
			
        if (maxCharsChanged)
        {
            textInput.maxChars = _maxChars;
            maxCharsChanged = false;
        }
    } 
    
    /**
     *  @private
     */
    override protected function setValue(newValue:Number):void
    {
        super.setValue(newValue);
        
        applyDisplayFormatFunction();
    }
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == textInput)
        {
            textInput.focusEnabled = false;
            textInput.maxChars = _maxChars;
            // Restrict to digits, minus sign, decimal point, and comma
            textInput.restrict = "0-9\\-\\.\\,";
            textInput.addEventListener(FlexEvent.ENTER,
                                       textInput_enterHandler);
            textInput.addEventListener(FocusEvent.FOCUS_OUT, 
                                       textInput_focusOutHandler); 
            textInput.text = value.toString();
            // Set the the textInput to be wide enough to display
            // widest possible value. 
            textInput.widthInChars = calculateWidestValue(); 
            
        }
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        if (instance == textInput)
        {
            textInput.removeEventListener(FlexEvent.ENTER, 
                                          textInput_enterHandler);
        }
    }

    /**
     *  @private
     */
    override protected function enableSkinParts(value:Boolean):void
    {
        super.enableSkinParts(value);
        if (textInput)
            textInput.enabled = value;
    }   

    /**
     *  @private
     */
    override public function setFocus():void
    {
        if (stage)
        {
            stage.focus = textInput.textView;
            textInput.textView.setSelection();
        }
    }
    
    /**
     *  @private
     */
    override protected function isOurFocus(target:DisplayObject):Boolean
    {
        return target == textInput.textView;
    }

    /**
     *  @private
     *  Calls commitTextInput() before stepping.
     */
    override public function step(increase:Boolean = true):void
    {
        commitTextInput();
        
        super.step(increase);
    }
    
    //--------------------------------------------------------------------------
    // 
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Commits the current text of <code>textInput</code> 
     *  to the <code>value</code> property. 
     *  This method uses the <code>nearestValidValue()</code> method 
     *  to round the input value to the closest multiple of 
     *  the <code>valueInterval</code> property, 
     *  and constrains the value to the range defined by the 
     *  <code>maximum</code> and <code>minimum</code> properties.
     */
    protected function commitTextInput(dispatchChange:Boolean = false):void
    {
        var inputValue:Number = Number(textInput.text);
        var prevValue:Number = value;
        
        if (textInput.text == "" || (inputValue != value && 
            (Math.abs(inputValue - value) >= 0.000001 || isNaN(inputValue))))
        {
            setValue(nearestValidValue(inputValue, valueInterval));
            
            // Dispatch valueCommit if the display needs to change.
            if (value == prevValue && inputValue != prevValue)
                dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
        }
        
        if (dispatchChange)
        {
            if (value != prevValue)
                dispatchEvent(new Event(Event.CHANGE));
        }
    }
    
    //--------------------------------------------------------------------------
    // 
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Helper method that returns a number corresponding
     *  to the length of the maximum value displayable in 
     *  the textInput.  
     */
    private function calculateWidestValue():Number
    {
        var widestNumber:Number = minimum.toString().length >
                              maximum.toString().length ?
                              minimum :
                              maximum;
    	widestNumber += stepSize;
    	
    	if (displayFormatFunction != null)
    	    return displayFormatFunction(widestNumber).length;
    	else 
    	   return widestNumber.toString().length;
    }
    
    /**
     *  @private
     *  Helper method that applies the displayFormatFunction  
     */
    private function applyDisplayFormatFunction():void
    {
        if (displayFormatFunction != null)
            textInput.text = displayFormatFunction(value);
        else
            textInput.text = value.toString();
    }
    
    //--------------------------------------------------------------------------
    // 
    //  Event handlers
    //
    //--------------------------------------------------------------------------
        
    /**
     *  @private
     *  When the enter key is pressed, NumericStepper commits the
     *  text currently displayed.
     */
    private function textInput_enterHandler(event:Event):void
    {
        commitTextInput(true);
    }
    
    /**
     *  @private
     *  When the enter key is pressed, NumericStepper commits the
     *  text currently displayed.
     */
    private function textInput_focusOutHandler(event:Event):void
    {
        commitTextInput(true);
    }
}

}
