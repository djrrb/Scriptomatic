#!/bin/sh
set -e

buildInstances=false


# build static instances
if $buildInstances
then
    echo "Generating Static TTFs"
    fontmake -m "JobClarendonVariableBeta.designspace" -i -o ttf --no-production-names --no-subset

    echo "Generating Static OTFs"
    fontmake -m "JobClarendonVariableBeta.designspace" -i -o otf --no-production-names --no-subset

fi

echo "Generating Variable TTFs"
fontmake -m "ExtendomaticVariable-VF.designspace" -o variable --no-production-names --no-subset


echo "Post processing"

# collect fonts for post-processing
vfs=$(ls variable_ttf/*.ttf)
all_ttfs=$(ls variable_ttf/*.ttf)
all_fonts=$(ls variable_ttf/*.ttf)

# autohint instances and add dsig
if $buildInstances
then

    all_ttfs=$(ls instance_ttf/*.ttf variable_ttf/*.ttf)
    all_fonts=$(ls instance_ttf/*.ttf instance_otf/*.otf variable_ttf/*.ttf)
    static_ttfs=$(ls instance_ttf/*.ttf)
    for ttf in $static_ttfs
    do
        gftools fix-dsig -f $ttf;
        ttfautohint $ttf "$ttf.fix";
        if [ -f "$ttf.fix" ]
        then
            mv "$ttf.fix" $ttf
        fi
    done
fi


echo "Autohinting variable fonts"
for vf in $vfs
do
	gftools fix-dsig -f $vf;
	#add-variable-to-names.py $vf;
	#ttfautohint-vf --stem-width-mode nnn $vf "$vf.fix";

    if [ -f "$vf.fix" ]
    then
        mv "$vf.fix" $vf
    fi
done

#gftools fix-meta $vfs;
#mv "$vf.fix" $vf;

echo "Dropping MVAR"
for vf in $vfs
do
	ttx -f -x "MVAR" $vf; # Drop MVAR. Table has issue in DW
	rtrip=$(basename -s .ttf $vf)
	new_file=variable_ttf/$rtrip.ttx;
	rm $vf;
	ttx $new_file
	rm $new_file
done

echo "Fixing Hinting"
for ttf in $all_ttfs
do
    echo 'fixing hinting' $ttf
	gftools fix-hinting $ttf;
    if [ -f "$ttf.fix" ]
    then
        mv "$ttf.fix" $ttf
    fi
done

echo "Done"