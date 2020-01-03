function chanlocs = chanlocsseek(chan_name)
load([pwd,'\chanlocsposi.mat']);
labeltotal = lower({chantotal.labels});
for s = 1:length(chan_name)
    chanlocs(1,s).labels = chan_name{s};
    poi = strmatch(lower(chanlocs(1,s).labels),labeltotal,'exact');
    if ~isempty(poi)
        chanlocs(1,s).theta = chantotal(1,poi).theta;
        chanlocs(1,s).radius = chantotal(1,poi).radius;
        chanlocs(1,s).X = chantotal(1,poi).X;
        chanlocs(1,s).Y = chantotal(1,poi).Y;
        chanlocs(1,s).Z = chantotal(1,poi).Z;
        chanlocs(1,s).sph_theta = chantotal(1,poi).sph_theta;
        chanlocs(1,s).sph_phi = chantotal(1,poi).sph_phi;
        chanlocs(1,s).sph_radius = chantotal(1,poi).sph_radius;
        chanlocs(1,s).type = [];
        chanlocs(1,s).urchan = s;
    end
    chanlocs(1,s).ref    = '';
end