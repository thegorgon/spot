class Color
  def self.hsv_to_rgb(h, s, v)
    h, s, v = [0, [360, h].min].max, [0, [100, s].min].max, [0, [100, v].min].max
    s, v = s / 100.0, v / 100.0
    
    if (s == 0)
      r, g, b = v, v, v
    else
      h /= 60.0
      i = h.floor
      f = h - i
      p = v * (1 - s)
      q = v * (1 - s * f)
      t = v * (1 - s * (1 - f))
      case i
      when 0
        r, g, b = v, t, p
      when 1
        r, g, b = q, v, p
      when 2
        r, g, b = p, v, t
      when 3
        r, g, b = p, q, v
      when 4
        r, g, b = t, p, v
      else
        r, g, b = v, p, q
      end
    end
    [(r * 255).round, (g * 255).round, (b * 255).round]
  end
  
  def self.rgb_to_hex(r, g, b)
    ['#', "%02x" % r, "%02x" % g, "%02x" % b].join
  end
  
  def self.hex_series(start, finish=nil, step=1)
    finish ||= start
    start.step(finish, step).collect do |i|
      hue = (i * 360/100.0 * 63).modulo(360)
      saturation = 60
      lightness = 60
      r, g, b = hsv_to_rgb(hue, saturation, lightness)
      rgb_to_hex(r, g, b)
    end
  end
end