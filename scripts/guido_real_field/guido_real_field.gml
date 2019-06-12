/// @param min
/// @param max
/// @param unit
/// @param length
/// @param [variableName]
/// @param [widgetName]

var _min          = argument[0];
var _max          = argument[1];
var _unit         = argument[2];
var _length       = argument[3];
var _variable     = ((argument_count > 4) && is_string(argument[4]))? argument[4] : undefined;
var _widget_name = ((argument_count > 5) && is_string(argument[5]))? argument[5] : undefined;


//Find widget data
if (!is_string(_widget_name)) _widget_name = _variable;
if (_widget_name == undefined)
{
    _widget_name = "AUTO " + string(__guido_auto_widget) + ", real field, variable=\"" + string(_variable) + "\"";
    ++__guido_auto_widget;
}

var _widget_array = __guido_widget_find(_widget_name, false);
if (_widget_array[__GUIDO_WIDGET.NEW])
{
    var _value = _min;
    if (__guido_variable_exists(_variable)) _value = __guido_limit_real(__guido_variable_get(_variable), _min, _max, _unit);
    
    _widget_array[@ __GUIDO_WIDGET.VALUE       ] = _value;
    _widget_array[@ __GUIDO_WIDGET.FIELD_STRING] = guido_string_format(_value);
    __guido_variable_set(_variable, _value);
}

var _value        = _widget_array[__GUIDO_WIDGET.VALUE       ];
var _old_state    = _widget_array[__GUIDO_WIDGET.STATE       ];
var _field_string = _widget_array[__GUIDO_WIDGET.FIELD_STRING];
var _new_state    = GUIDO_STATE.NULL;


//Position widget
var _widget_w = _length;
var _widget_h = (_field_string == "")? string_height(" ") : string_height(_field_string);

var _l = guido_x;
var _t = guido_y;
var _r = _l + _widget_w;
var _b = _t + _widget_h;


//Handle cursor and keyboard interaction
if (point_in_rectangle(__guido_cursor_x, __guido_cursor_y, _l, _t, _r, _b))
{
    if (!is_string(guido_cursor_over_widget))
    {
        guido_cursor_over_widget = _widget_name;
        
        _new_state = (_old_state == GUIDO_STATE.DOWN)? GUIDO_STATE.DOWN : GUIDO_STATE.OVER;
        if (__guido_cursor_released && (_old_state == GUIDO_STATE.DOWN)) _new_state = GUIDO_STATE.CLICK;
        if (__guido_cursor_pressed  && (_old_state == GUIDO_STATE.OVER)) _new_state = GUIDO_STATE.DOWN;
    }
}

if (_new_state == GUIDO_STATE.CLICK)
{
    _widget_array[@ __GUIDO_WIDGET.FIELD_POS] = 0;
}

if (__guido_focus == _widget_name)
{
    _widget_array[@ __GUIDO_WIDGET.FIELD_FOCUS] = true;
    var _field_pos = string_length(_field_string) - _widget_array[__GUIDO_WIDGET.FIELD_POS];
    
    if (keyboard_check_pressed(vk_anykey) && (ord(keyboard_lastchar) >= 32))
    {
        _field_string = string_insert(keyboard_lastchar, _field_string, _field_pos+1);
        keyboard_lastchar = "";
        _widget_array[@ __GUIDO_WIDGET.FIELD_STRING] = _field_string;
    }
    
    if (keyboard_check_pressed(vk_backspace))
    {
        _field_string = string_delete(_field_string, _field_pos, 1);
        _widget_array[@ __GUIDO_WIDGET.FIELD_STRING] = _field_string;
    }
    
    if (keyboard_check_pressed(vk_delete))
    {
        _field_string = string_delete(_field_string, _field_pos+1, 1);
        _widget_array[@ __GUIDO_WIDGET.FIELD_STRING] = _field_string;
        
        _field_pos = min(_field_pos + 1, string_length(_field_string));
        _widget_array[@ __GUIDO_WIDGET.FIELD_POS] = string_length(_field_string) - _field_pos;
    }
    
    if (keyboard_check_pressed(vk_right))
    {
        _field_pos = min(_field_pos + 1, string_length(_field_string));
        _widget_array[@ __GUIDO_WIDGET.FIELD_POS] = string_length(_field_string) - _field_pos;
    }
    
    if (keyboard_check_pressed(vk_left))
    {
        _field_pos = max(_field_pos - 1, 0);
        _widget_array[@ __GUIDO_WIDGET.FIELD_POS] = string_length(_field_string) - _field_pos;
    }
    
    if (keyboard_check_released(vk_enter)) __guido_focus = undefined;
}

if ((__guido_focus != _widget_name) && _widget_array[__GUIDO_WIDGET.FIELD_FOCUS])
{
    _widget_array[@ __GUIDO_WIDGET.FIELD_FOCUS] = false;
    _value = real(_field_string);
    _value = __guido_limit_real(_value, _min, _max, _unit);
    _field_string = guido_string_format(_value);
    __guido_variable_set(_variable, _value);
    
    _widget_array[@ __GUIDO_WIDGET.VALUE       ] = _value;
    _widget_array[@ __GUIDO_WIDGET.FIELD_STRING] = _field_string;
}


//Draw
draw_rectangle(_l, _t, _r, _b, true);

if (__guido_focus == _widget_name)
{
    draw_rectangle(_l+2, _t+2, _r-2, _b-2, false);
    
    var _old_colour = draw_get_colour();
    draw_set_colour(GUIDO_INVERSE_COLOUR);
    draw_set_halign(fa_right);
    draw_text(_r-2, _t, string_insert(((current_time mod 300) < 200)? "|" : " ", _field_string, _field_pos+1));
    draw_set_halign(fa_left);
    draw_set_colour(_old_colour);
}
else if (_new_state == GUIDO_STATE.OVER)
{
    draw_rectangle(_l+2, _t+2, _r-2, _b-2, false);
    
    var _old_colour = draw_get_colour();
    draw_set_colour(GUIDO_INVERSE_COLOUR);
    draw_set_halign(fa_right);
    draw_text(_r-2, _t, _field_string);
    draw_set_halign(fa_left);
    draw_set_colour(_old_colour);
}
else
{
    draw_set_halign(fa_right);
    draw_text(_r-2, _t, _field_string);
    draw_set_halign(fa_left);
}


//Update IM state
guido_x += GUIDO_WIDGET_SEPARATION + _widget_w;
__guido_line_height = max(__guido_line_height, _widget_h);


//Update widget state
if (_widget_array[__GUIDO_WIDGET.NEW_STATE] == GUIDO_STATE.NULL) _widget_array[@ __GUIDO_WIDGET.NEW_STATE] = _new_state;


//Reset draw state
guido_prev_name  = _widget_name;
guido_prev_state = _new_state;
guido_prev_value = _value;

return _new_state;