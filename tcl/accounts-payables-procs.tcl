ad_library {
    procedures for the Accounts Payables package

    @author ported by Torben Brosten (torben@kappacorp.com)
    @creation-date October 2005

}

ad_proc -public qap_integer_to_text {
    {-number:required "0"}
    {-locale:required ""}
} {
    Returns the number represented as a string of internationalized phrases, 
    using the locale's grammar.
    Returns the decimal number (unchanged) if the locale is not represented.
    Read the source comments of this
    procedure for details on adding locale grammar not yet supported.

    @param number  translates whole numbers, ignores everything to right of decimal point
                   assumes number has no formatting separators
    @param locale 
    @author Torben Brosten

} {

    # Num2text is fragmented into separate files in sql-ledger. Each language has a
    # directory with language specific files in a subdirectory of directory sql-ledger/locale
    # For example, consider the French language modifications:
    # perl num2text code is in file: sql-ledger/locale/fr/Num2text
    # Language proper name is in file: sql-ledger/locale/fr/LANGUAGE
    # Contact info about the procedure is in: sql-ledger/locale/fr/COPYING

    # isolate the integer part
    # Perhaps this should be done mathematically to avoid problems with numbers using something
    # other than a decimal point when represented by some locales.
    set decimal_loc [string first "." number]
    
    if {$decimal_loc > 0} {
        set integer [string range 0 $decimal_loc]
    } elseif { $decimal_loc == 0 } {
        set integer 0
    } elseif { $decimal_loc == -1 } {
        set integer $number
    }
 
    set digit_count [string length $integer]
    
    # e_plus means e+ (tcl notation for power of ten), ie ones, thousands, millions, billions, trillions, quadrillions, quintillions
    #set e_plus_list [list 0 3 6 9 12 15 18]
    
    # sets e_plus_array into groups of NNN where N is a digit between 0 and 9
    for {set i 0} {$i < $digit_count} {incr i 3} {
        # prepending zeros for possible hanging left most digit(s) of number
        set e_plus_array($i) [string range "000[string range $integer [expr $digit_count - $i - 3 ] [expr $digit_count - $i - 1]]" end-2 end]
    }

    # make substitutions based on grammatical rules. 
    # There are locale specific exceptions (see switch conditions below).
    # Each loop expands an e_plus NNN grouping into a string of translation-keys
    foreach e_plus [array names e_plus_array] {

        switch -exact -- $locale {
            
    
            default {
                set first_digit [string range $e_plus_array($e_plus) end-2 end-2] 
                set middle_digit [string range $e_plus_array($e_plus) end-1 end-1]
                set last_digit [string range $e_plus_array($e_plus) end end]

                if { ![string equal $first_digit "0"] } {
                    # must be something like 100 ie. one hundred
                    set written_array($e_plus) "#accounts-ledger.${first_digit}# #accounts-ledger.10__2#"
                }
                if { $middle_digit > 1 } {
                    if { [string equal $last_digit "0"] } {
                        # 20, 30, 40, 50, 60, 70, 80 and 90 have specific keys
                        append written_array($e_plus) " #accounts-ledger.${middle_digit}0#"
                    } else {
                        # 21..
                        append written_array($e_plus) " #accounts-ledger.${middle_digit}0# #accounts-ledger.${last_digit}#"
                    }
                } elseif { [string equal $middle_digit "1"] } {
                    # 10 .. 19 do not use grammar because there are so many locale variations
                    append written_array($e_plus) " #accounts-ledger.${middle_digit}${last_digit}#"
                } elseif { ![string equal $last_digit "0"] } {
                    # 1 .. 9
                    append written_array($e_plus) " #accounts-ledger.${last_digit}#"
                }
                # if NNN was 000 then written_array might not exist..
                if { $e_plus > 0 && [info exists written_array($e_plus)] } {
                    append written_array($e_plus) " #accounts-ledger.10__${e_plus}#"
                }
            }
    
        }
    }
    # combine string for return
    set written_number ""
    for {set iii 0} {$iii < $digit_count} {incr iii 3} {
        if { [info exists written_array($iii)] } {
            set written_number "$written_array($iii) ${written_number}"
        }
    }
    if {[string length [string trim $written_number]] == 0 } {
        # must be zero
        return "#accounts-ledger.0#"
    } else {
        return [string trim $written_number]
    }
}
