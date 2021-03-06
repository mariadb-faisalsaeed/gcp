. ../config-xonotic-env.sh

gcloud beta container --project $PROJECT_ID clusters create xonotic-game-us \
--region us-central1 \
--cluster-version 1.19 \
--tags=game-server \
--scopes=gke-default \
--machine-type e2-standard-2 \
--image-type "COS_CONTAINERD" \
--disk-type "pd-standard" --disk-size 100 \
--service-account "$SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com" \
--num-nodes 1 \
--logging=SYSTEM,WORKLOAD \
--monitoring=SYSTEM \
--enable-ip-alias --network "projects/$PROJECT_ID/global/networks/demo-vpc" \
--subnetwork "projects/$PROJECT_ID/regions/us-central1/subnetworks/subnet-us" \
--enable-autoscaling --min-nodes 1 --max-nodes 3 \
--addons HorizontalPodAutoscaling,HttpLoadBalancing,NodeLocalDNS,GcePersistentDiskCsiDriver \
--no-enable-autoupgrade \
--enable-autorepair \
--max-surge-upgrade 1 \
--max-unavailable-upgrade 0 \
--enable-shielded-nodes --shielded-secure-boot --shielded-integrity-monitoring \
--node-locations "us-central1-a"
#,"us-central1-b","us-central1-c"
