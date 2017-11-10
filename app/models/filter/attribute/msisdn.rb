class Filter::Attribute::Msisdn < Filter::Attribute::Base
  def apply
    association_chain.where(:msisdn => PhonyRails.normalize_number(msisdn))
  end

  def apply?
    !!msisdn
  end

  private

  def msisdn
    params[:msisdn]
  end
end
