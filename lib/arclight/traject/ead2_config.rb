# frozen_string_literal: true

# SENYLRC customizations to top-level (collection-level)
# EAD2002 indexing rules specified in ArcLight core.
# See: https://github.com/projectblacklight/arclight/blob/main/lib/arclight/traject/ead2_config.rb

require 'arclight'

settings do
  provide 'component_traject_config', File.join(__dir__, 'ead2_component_config.rb')
end

load_config_file(File.expand_path("#{Arclight::Engine.root}/lib/arclight/traject/ead2_config.rb"))

# SENYLRC: Get title with formatting tags intact
to_field 'title_html_ssm', extract_xpath('/ead/archdesc/did/unittitle', to_text: false)

# SENYLRC: Remove genreform from being grouped in with Subject
to_field 'access_subjects_ssim',
         extract_xpath('/ead/archdesc/controlaccess', to_text: false) do |_record, accumulator, context|
  context.output_hash['access_subjects_ssim'] = nil
  accumulator.map! do |element|
    %w[subject function occupation].map do |selector|
      element.xpath(".//#{selector}").map(&:text)
    end
  end.flatten!
end

# SENYLRC: preserve formatting tags in normalized titles
to_field 'normalized_title_html_ssm' do |_record, accumulator, context|
  title = context.output_hash['title_html_ssm']&.first&.to_s
  dates = context.output_hash['normalized_date_ssm']&.first
  accumulator << Arclight::NormalizedTitle.new(title, dates).to_s
end

# SENYLRC: Digital Objects using standard ArcLight attributes
to_field 'digital_objects_ssm',
         extract_xpath('/ead/archdesc/did/dao|/ead/archdesc/dao', to_text: false) do |_record, accumulator, context|
  context.output_hash['digital_objects_ssm'] = nil
  accumulator.map! do |dao|
    label = dao.attributes['title']&.value ||
            dao.attributes['xlink:title']&.value ||
            dao.xpath('daodesc/p')&.text
    href = (dao.attributes['href'] || dao.attributes['xlink:href'])&.value
    Arclight::DigitalObject.new(label:, href:).to_json
  end
end

# SENYLRC: Online content detection
to_field 'has_online_content_ssim',
         extract_xpath('.//dao') do |_record, accumulator, context|
  context.output_hash['has_online_content_ssim'] = nil
  accumulator.replace([accumulator.any?])
end

# SENYLRC: Wrap carrier extents in parentheses per DACS
to_field 'extent_ssm' do |record, accumulator, context|
  context.output_hash['extent_ssm'] = nil
  physdescs = record.xpath('/ead/archdesc/did/physdesc')
  extents_per_physdesc = physdescs.map do |physdesc|
    extents = physdesc.xpath('./extent').map do |e|
      if e.attributes['altrender']&.value == 'carrier'
        "(#{e.text.strip})"
      else
        e.text.strip
      end
    end
    extents.join(' ') unless extents.empty?
  end
  accumulator.concat(extents_per_physdesc)
end

to_field 'extent_tesim' do |_record, accumulator, context|
  context.output_hash['extent_tesim'] = nil
  accumulator.concat context.output_hash['extent_ssm'] || []
end

# SENYLRC: Sort collection record after components
to_field 'sort_isi' do |_record, accumulator, context|
  context.output_hash['sort_isi'] = nil
  accumulator << 999_999
end

# SENYLRC: Names excluding repository
name_first_iteration = true
NAME_ELEMENTS.map do |selector|
  to_field 'names_ssim', extract_xpath("//#{selector}[not(parent::repository)]"),
           unique do |_record, accumulator, context|
    context.output_hash['names_ssim'] = nil if name_first_iteration
    accumulator.map!
  end

  to_field "#{selector}_ssim", extract_xpath("//#{selector}[not(parent::repository)]"),
           unique do |_record, accumulator, context|
    context.output_hash["#{selector}_coll_ssim"] = nil if name_first_iteration
    accumulator.map!
  end
  name_first_iteration = false
end

# SENYLRC: Language fields
to_field 'language_ssim', extract_xpath('/ead/archdesc/did/langmaterial/language') do |_record, accumulator, context|
  context.output_hash['language_ssim'] = nil
  accumulator.map!
end

to_field 'langmaterial_ssim', extract_xpath('/ead/archdesc/did/langmaterial[not(descendant::language)]')
