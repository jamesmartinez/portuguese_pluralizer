# encoding: utf-8
class String

  PORTUGUESE_CIRCUMFLEX_VOWELS = "êô"
  PORTUGUESE_TILDE_VOWELS = "ãõ"
  PORTUGUESE_ACUTE_VOWELS = "áéíó"
  PORTUGUESE_ACCENTED_VOWELS = PORTUGUESE_ACUTE_VOWELS + PORTUGUESE_CIRCUMFLEX_VOWELS + PORTUGUESE_TILDE_VOWELS
  PORTUGUESE_NON_ACCENTED_VOWELS = "aeiou"
  PORTUGUESE_VOWELS = PORTUGUESE_NON_ACCENTED_VOWELS + PORTUGUESE_ACCENTED_VOWELS
  PORTUGUESE_CONSONANTS = "bcçdfghjlmnpqrsvxz"

  PORTUGUESE_ACUTE_VOWEL_MAP = {
    'a' => 'á',
    'e' => 'é',
    'i' => 'í',
    'o' => 'ó',
    'u' => 'ú'
  }
  
  PORTUGUESE_CIRCUMFLEX_VOWEL_MAP = {
    'e' => 'ê',
    'o' => 'ô'
  }

  PORTUGUESE_TILDE_VOWEL_MAP = {
    'a' => 'ã',
    'o' => 'õ'
  }
  
  PORTUGUESE_UNACCENT_VOWEL_MAP = {}
  PORTUGUESE_UNACCENT_VOWEL_MAP.merge!(PORTUGUESE_ACUTE_VOWEL_MAP.invert)
  PORTUGUESE_UNACCENT_VOWEL_MAP.merge!(PORTUGUESE_CIRCUMFLEX_VOWEL_MAP.invert)
  PORTUGUESE_UNACCENT_VOWEL_MAP.merge!(PORTUGUESE_TILDE_VOWEL_MAP.invert)
  
  def portuguese_pluralizer_unaccent
    PORTUGUESE_UNACCENT_VOWEL_MAP.fetch(self,self)
  end

  def portuguese_pluralizer_has_accent?
    if m = match(/["#{PORTUGUESE_ACCENTED_VOWELS}"]/)
      true
    else
      false
    end
  end
  
  def portuguese_pluralizer_last_vowel
    m = match(/\w*(["#{PORTUGUESE_VOWELS}"])["#{PORTUGUESE_CONSONANTS}"]?$/)
    m[1].to_s
  end
 
  def portuguese_pluralizer_acute
    PORTUGUESE_ACUTE_VOWEL_MAP.fetch(self,self)
  end
  
  def portuguese_pluralizer_unacute
    PORTUGUESE_ACUTE_VOWEL_MAP.invert.fetch(self,self)
  end

  def portuguese_pluralizer_circumflex
    PORTUGUESE_CIRCUMFLEX_MAP.fetch(self,self)
  end

  def portuguese_pluralizer_uncircumflex
    PORTUGUESE_CIRCUMFLEX_MAP.invert.fetch(self,self)
  end
  
  def portuguese_pluralizer_tilde
    PORTUGUESE_TILDE_VOWEL_MAP.fetch(self,self)
  end

  def portuguese_pluralizer_untilde
    PORTUGUESE_TILDE_VOWEL_MAP.invert.fetch(self,self)
  end
 
  def portuguese_pluralizer_last_consonant
    m = match(/\w*["#{PORTUGUESE_VOWELS}"]?(["#{PORTUGUESE_CONSONANTS}"])$/)
    m[1].to_s
  end
  
  def portuguese_pluralizer_last_letter
    self[-1]
  end

  def pluralize_portuguese
    case self
    # If the singular ends in -n just add -s
    when /\w*["#{PORTUGUESE_VOWELS}"]n$/ then self + 's'
    # If the singular ends in -m, drop -m and add -ns
    when /\w*["#{PORTUGUESE_VOWELS}"]m$/ then gsub(/m$/,'ns') 
    # If the singular ends in ãe just add -s
    when /\w*ãe$/ then self + 's'
    # If the singular ends with -ção or -são add -ões
    when /\w*[çs]ão$/ then gsub(/ão/,"ões")
    # If the singular ends with r,s,z or x...
    when /\w*[rszx]$/ 
      # If the singular ends with s or x
      if portuguese_pluralizer_last_letter == "s" or portuguese_pluralizer_last_letter == "x"
        # And the last vowel is accented, unaccent it before adding -es
        if portuguese_pluralizer_last_vowel.portuguese_pluralizer_has_accent?
          gsub!(/#{portuguese_pluralizer_last_vowel}/,portuguese_pluralizer_last_vowel.portuguese_pluralizer_unaccent)
          self + 'es'
        # But if the last vowel isn't accented and ends in s just return singular as is for plural
        else
          self
        end
      # If it doesn't end in s or x but r or z just add -es
      else   
        self + 'es'
      end
    # If ends with an unaccented vowel and l
    when /\w*["#{PORTUGUESE_NON_ACCENTED_VOWELS}"]l$/
      # And the last vowel is i or e
      if portuguese_pluralizer_last_vowel == 'i' or portuguese_pluralizer_last_vowel == 'e'
        # And if it has an accent swap the last vowel + l with -eis
        if portuguese_pluralizer_has_accent?
          gsub(/#{portuguese_pluralizer_last_vowel}l$/,"eis")
        # And if it doesn't have an acccent and the last vowel is i, swap the last vowel + l with -is
        elsif portuguese_pluralizer_last_vowel == 'i'
          gsub(/#{portuguese_pluralizer_last_vowel}l$/,"is") 
        # Otherwise if it doesn't have an accent and the the last vowel is e, give the last vowel an acute accent and add -is
        elsif portuguese_pluralizer_last_vowel == 'e'
          gsub(/#{portuguese_pluralizer_last_vowel}l$/,portuguese_pluralizer_last_vowel.portuguese_pluralizer_acute + "is") 
        end
      # If the last vowel is o and 
      elsif portuguese_pluralizer_last_vowel == 'o'
        # and has an accent just turn the -l to -is
        if portuguese_pluralizer_has_accent?
          gsub(/l$/,"is")
        else
          gsub(/#{portuguese_pluralizer_last_vowel}l$/,portuguese_pluralizer_last_vowel.portuguese_pluralizer_acute + "is")
        end
      else
        gsub(/l$/,"is")
      end
    end
  end

end
