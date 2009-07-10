if(typeof Prototype == 'undefined')
  throw("Datebalks.js requires including the prototype.js library");

// ==========================================================================
//
// Simple Extensions to existing objects
//
// ==========================================================================

Object.extend(String.prototype, {
    startsWith: function(string) {
        return (this.slice(0, string.length) == string)
    }
});

Object.extend(Date.prototype, {
    
    addDays: function(days) {
        this.setMilliseconds((this.getMilliseconds() + 1000*60*60*24*days));
        return this;
    },
    
    addMonths: function(months) {
        this.setMonth(this.getMonth() + months);
        return this;
    }
});

// ==========================================================================
//
// Datebalks: "natural date" parsing
//
// You can localize this by changing the strings here and also by changing the 
// order of precedence in the resetDictionary() function. The patterns will 
// likely need to be changed also as many are hard-coded for simplicity.
//
// Patterns work as follows: 
//    - Return a date => match!
//    - Return null   => no match
// 
// This makes pattern matching a bit more flexible that regexp based matching 
// only though a bit more complex too.
//
// ==========================================================================

var Datebalks = {

    SpecificDays:   ['yesterday','today','tomorrow'],
    Weekdays:       ['sundays','mondays','tuesdays','wednesdays','thursdays','fridays','saturdays'],
    Durations:      ['days','weeks','months'],
    Directions:     ['in','next','this','last','ago'],
    RelativeMoves:  ['after', 'before'],
    Months:         ['january','feburary','march','april','may','june','july','august','september','october','november','december'],
    Positions:      ['first', 'second', 'third', 'fourth'],
    Suffixes:       ['st','nd','rd','th'],

    parse: function(string) {
        return new Datebalks.Context().parse(string);
    }
};


Datebalks.Context = Class.create();
Object.extend(Datebalks.Context.prototype, {

    initialize: function() {
        this.matching_number_or_date = false;
        this.resetDictionary();
        this.tokens = [];
        this.token  = '';
    },

    resetDictionary: function() {
        this.dictionary = [].concat(
            Datebalks.SpecificDays,
            Datebalks.Weekdays,
            Datebalks.Durations,
            Datebalks.Directions,
            Datebalks.RelativeMoves,
            Datebalks.Months,
            Datebalks.Positions,
            Datebalks.Suffixes
        );
    },
    
    parse: function(string) {
        return this.parseExpandedString(
            this.expandString(string.toLowerCase())
        );
    },
    
    expandString: function(string) {

        for (i=0; i<string.length; i++) {
    
            char = string.charAt(i);
            
            if (char.match(/\s/)) {
                this.expandToken();
                this.matching_number_or_date = false;
            }
            else if (char.match(/\d|[+\-\./]/)) {
                if (! this.matching_number_or_date) {
                    this.expandToken();
                    this.matching_number_or_date = true;
                }
                this.token += char;
            }
            else if (char.match(/[a-z]/)){
                if (this.matching_number_or_date) {
                    this.expandToken();
                    this.matching_number_or_date = false;
                }
                var token = (this.token += char);
                words = this.dictionary.findAll(function(word) {
                    return word.startsWith(token);
                });
                if (words.length == 0) {
                    if (this.token.length == 1) {
                        this.token = '';
                    }
                    else {
                        this.expandToken();
                        i--; // Reprocess this char
                    }
                }
                else {
                    this.dictionary = words;
                }
            }
            else {
                // This is a token break but we ignore the character.
                this.expandToken();
            }
        }
        this.expandToken();

        return this.tokens.join(' ');
    },
    
    expandToken: function() {
        token = this.token.strip();
        if (token.length > 0) {
           token = this.matching_number_or_date ? this.token : this.bestMatch();
            if ((token != null) && (token != ''))
                this.tokens.push(token.replace(/^[-+.\/]+/,'').replace(/[-+.\/]+$/,''));
        }
        this.resetDictionary();
        this.token = '';
    },

    bestMatch: function() {
        index = this.dictionary.indexOf(this.token);
        index = (index == -1)? 0 : index;
        return this.dictionary[index];
    },

    Patterns: [

        // yesterday, today and tommorow
        function (string) {
            index = Datebalks.SpecificDays.indexOf(string);
            return (index != -1)? new Date().addDays(index - 1) : null;
        },
        
        // last friday, next monday
        // next month, last week
        // in 2 days, in 3 weeks, in 1 month, in 3 mondays
        // 3 days ago, 2 weeks ago, 1 month ago, 3 sundays ago
        function (string) {
            if (c = string.match(/^(in |next |last |this )?(\d+ )?([a-z]+)( ago)?$/)) {

                dir  = ((c[1] == 'last ') || (c[4] == ' ago'))? -1 : 1;
                mag  = parseInt(c[2]);
                mag  = isNaN(mag)? 1 : mag;
                date = new Date();

                switch(c[3]) {
                    case 'days'  : 
                        date.addDays(dir * mag);        break;
                    case 'weeks' : 
                        date.addDays(dir * mag * 7);    break;
                    case 'months': 
                        date.addMonths(dir * mag);      break;
                    case 'sundays': 
                    case 'mondays': 
                    case 'tuesdays': 
                    case 'wednesdays': 
                    case 'thursdays': 
                    case 'fridays': 
                    case 'saturdays':
                        day = date.getDay();
                        wd  = Datebalks.Weekdays.indexOf(c[3]);
                        d1  = (wd >= day)? -7 : 0;
                        d2  = (wd <= day)?  7 : 0;
                        date.addDays((dir == -1? d1 : d2) + wd - day);
                        date.addDays(dir * (mag - 1) * 7);
                        break;
                    default:
                        return null;
                }
                return date;
            }
            return null;
        },
        
        // dd.mm, dd-mm, dd/mm
        function (string) {
            if (c = string.match(/^(\d{1,2}).(\d{1,2})$/))
                return this.generateDate(null, c[2], c[1]);
            return null;
        },

        // yyyy-mm-dd, yyyy.mm.dd, yyyy/mm/dd
        function (string) {
            if (c = string.match(/^(\d{4}).(\d{1,2})(.(\d{1,2}))$/))
                return this.generateDate(c[1], c[2], c[4]);
            return null;
        },

        // dd.mm.yyyy, dd-mm-yyyy, mm.yyyy, mm-yyyy ...
        function (string) {
            if (c = string.match(/^((\d{1,2}).)?(\d{1,2}).(\d{4})$/))
                return this.generateDate(c[4], c[3], c[2]);
            return null;
        },

        // january, march 2007, april 2008...
        function (string) {
            if (c = string.match(/^([a-z]+)( \d{4})?$/)) {
                month = Datebalks.Months.indexOf(c[1]);
                return (typeof month == 'number')? this.generateDate(c[2], month+1,1) : null;
            }
            return null;
        },

        // january 14th, october 10 2008...
        function (string) {
            if (c = string.match(/^([a-z]+) (\d{1,2})( st| nd| rd| th)?( \d{1,2}| \d{4})?$/)) {
                month = Datebalks.Months.indexOf(c[1]);
                return (typeof month == 'number')? this.generateDate(c[4], month+1, c[2]) : null;
            }
            return null;
        },

        // 1st january, january 2008, 4 march 09, march, april
        function (string) {
            if (c = string.match(/^(\d{1,2})( st| nd| rd| th)? ([a-z]+)( \d{1,2}| \d{4})?$/)) {
                month = Datebalks.Months.indexOf(c[3]);
                return (typeof month == 'number')? this.generateDate(c[4], month + 1, c[1]) : null;
            }
            return null;
        },

        // 4th, 7, 12th, 1st
        function (string) {
            if (c = string.match(/^(\d{1,2})( st| nd| rd| th)?$/)) {
                today = new Date();
                date  = new Date();
                date.setDate(parseInt(c[1]));
                if (date < today)
                    date.setMonth(date.getMonth() + 1);
                return date;
            }
            return null;
        }
    ],


    parseExpandedString: function(string) {
        var context = this;
        var value   = null;
        this.Patterns.detect( function(f) { 
            return (value = f.apply(context, [string])); 
        });
        return value;
    },
    
    generateDate: function(year, month, day) {

        today = new Date();
        
        // Remove leading zeros from string arguments
        year  = (typeof year  == 'string')? year.replace(/^0+/,'')  : year;
        month = (typeof month == 'string')? month.replace(/^0+/,'') : month;
        day   = (typeof day   == 'string')? day.replace(/^0+/,'')   : day;
        
        // Set defaults for unspecified components
        day   = day   ? parseInt(day)     : 1;
        month = month ? parseInt(month)-1 : today.getMonth();
        year  = year  ? parseInt(year)    : today.getFullYear() + (month < today.getMonth() ? 1 : 0);
        
        // Fix year that have fewer than four digits
        year  = (year < today.getFullYear() % 2000 + 30)? year + 2000 : year;

        return new Date(year, month, day);
    }
});

// ==========================================================================
//
// Datebalks: widgets
//
// ==========================================================================

Object.extend(Datebalks, {

    appendPopupAndText: function(element) {
        
        element  = $(element);
        old_name = element.name;
        old_value = element.value;
        img_id   = element.id + '_pop_cal';
        sml_id   = element.id + '_date_output';
        inp_id   = element.id + '_date_parsed';

        // This little substitution is partially Rails specific.
        // 1. object[property] becomes object[property_text]
        // 2. Just appends _text to the name.
        element.name = old_name.gsub(/(\w+)\[([^\]]*)\]?$/, '#{2}_text');

        new Insertion.After(element, '<input id="'+ inp_id +'" type="hidden" name="'+ old_name +'" value="'+old_value+'" /><img id="' + img_id + '" src="/images/calendar.gif" class = "calendar_img" alt="Select date from calendar" width="20" height="17" style="cursor: pointer; padding-left: 0.5em; vertical-align: top;" /><br /><small id="'+ sml_id + '">&nbsp;</small>');

        Calendar.setup({
              inputField     :    element,
              ifFormat       :    "%B %e, %Y",
              button         :    img_id,
              align          :    "Tl",
              singleClick    :    true,
              onUpdate       :    function() { 
                xsml_id = element.id + '_date_output';
                xinp_id = element.id + '_date_parsed';
                $(xsml_id).update('&nbsp;'); 
                $(xinp_id).value = element.value 
              }
        });

        new Form.Element.DelayedObserver(element, 0.75, function() {
          
            xsml_id = element.id + '_date_output';
            xinp_id = element.id + '_date_parsed';
            if (element.value.strip() != '') {
                date = Datebalks.parse(element.value);
                if (date != null) {
                    date_text = date.print("%B %e, %Y");
                    $(xsml_id).update(date_text);
                    $(xinp_id).value = date_text;
                }
                else {
                    $(xsml_id).update('Date is not valid!');
                    $(xinp_id).value = '';
                }
            }
            else {
                $(xsml_id).update('No date selected');
                $(xinp_id).value = '';
            }
        });
    }
});

// ==========================================================================
//
// Datebalks: Lowpro behaviours
//
// ==========================================================================

if(typeof Event.addBehavior != 'undefined') {
    Event.addBehavior({
        '.datebalks': function() {
            Datebalks.appendPopupAndText(this);
        }
    });
}
