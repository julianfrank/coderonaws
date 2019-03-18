cd private
tf destroy -auto-approve
cd ../public
tf destroy -auto-approve
cd ../base
tf destroy -auto-approve