/// @param [labelOn]
/// @param [labelOff]
/// @param [variableName]
/// @param [elementName]

var _old_colour = draw_get_colour();

var _string_on    = ((argument_count > 0) && is_string(argument[0]))? argument[0] : "";
var _string_off   = ((argument_count > 1) && is_string(argument[1]))? argument[1] : _string_on;
var _variable     = ((argument_count > 2) && is_string(argument[2]))? argument[2] : undefined;
var _element_name = ((argument_count > 3) && is_string(argument[3]))? argument[3] : undefined;

if (!is_string(_element_name)) _element_name = _variable;
if (_element_name == undefined)
{
    _element_name = "AUTO " + string(__im_auto_element) + ", toggle, variable=\"" + string(_variable) + "\"";
    ++__im_auto_element;
}

var _element_array = __im_element_find(_element_name, false);
var _value         = _element_array[__IM_ELEMENT.VALUE  ];
var _old_state     = _element_array[__IM_ELEMENT.STATE  ];
var _handled       = _element_array[__IM_ELEMENT.HANDLED];

if (_handled)
{
    if (!_element_array[__IM_ELEMENT.ERRORED])
    {
        show_debug_message("IM: WARNING! Name \"" + _element_name + "\" is being used by two or more elements.");
        _element_array[@ __IM_ELEMENT.ERRORED] = true;
    }
    
    draw_set_colour(c_gray);
}

var _new_state = IM_MOUSE.NULL;



var _string_w = 24;
var _string_h = 24;

var _l = __im_pos_x;
var _t = __im_pos_y;
var _r = __im_pos_x + _string_w;
var _b = __im_pos_y + _string_h;



if (!_handled)
{
    if (point_in_rectangle(__im_mouse_x, __im_mouse_y, _l, _t, _r, _b))
    {
        if (!im_mouse_over_any)
        {
            im_mouse_over_any = true;
        
            _new_state = (_old_state == IM_MOUSE.DOWN)? IM_MOUSE.DOWN : IM_MOUSE.OVER;
            if (__im_mouse_released && (_old_state == IM_MOUSE.DOWN)) _new_state = IM_MOUSE.CLICK;
            if (__im_mouse_pressed  && (_old_state == IM_MOUSE.OVER)) _new_state = IM_MOUSE.DOWN;
        }
    }
}



draw_rectangle(_l, _t, _r, _b, true);

if (_value)
{
    draw_rectangle(_l+2, _t+2, _r-2, _b-2, false);
    
    if (_new_state == IM_MOUSE.OVER)
    {
        draw_set_colour(make_colour_rgb(255 - colour_get_red(_old_colour), 255 - colour_get_green(_old_colour), 255 - colour_get_blue(_old_colour)));
        draw_rectangle(_l+3, _t+3, _r-3, _b-3, true);
        draw_set_colour(_old_colour);
    }
}
else if (_new_state == IM_MOUSE.OVER) 
{
    draw_rectangle(_l+2, _t+2, _r-2, _b-2, true);
}

__im_pos_x += IM_ELEMENT_SEPARATION + _string_w;
__im_line_height = max(__im_line_height, _string_h);

var _string = _value? _string_on : _string_off;
if (_string != "") im_text(_string);

if (!_handled)
{
    if (_new_state == IM_MOUSE.CLICK)
    {
        _value = !_value;
        _element_array[@ __IM_ELEMENT.VALUE] = _value;
    
        if (is_string(_variable))
        {
            if (string_copy(_variable, 1, 7) == "global.")
            {
                variable_global_set(string_delete(_variable, 1, 7), _value);
            }
            else
            {
                variable_instance_set(id, _variable, _value);
            }
        }
    }
    
    _element_array[@ __IM_ELEMENT.STATE  ] = _new_state;
    _element_array[@ __IM_ELEMENT.HANDLED] = true;
}

draw_set_colour(_old_colour);

return _new_state;