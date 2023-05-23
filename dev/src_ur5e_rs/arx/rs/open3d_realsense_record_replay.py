
''' open3d with realsense example
  @link http://www.open3d.org/docs/release/tutorial/sensor/realsense.html
'''

import yaml
import open3d as o3d


rs_cfg_fname = "rs_cfg.yml"
odir = "./out/"
rgbd_log_fname = "rs_rgbd_streams.bag"


# init sensor
rs = o3d.t.io.RealSenseSensor()


with open(rs_cfg_fname) as rs_cf:
            with open(getattr(self, k), 'w') as f:
            yaml.dump(self, f)
  rs_cfg = o3d.t.io.RealSenseSensorConfig(json.load(cf))

rs.init_sensor(rs_cfg, 0, bag_filename)
rs.start_capture(True)  # true: start recording with capture
for fid in range(150):
    im_rgbd = rs.capture_frame(True, True)  # wait for frames and align them
    # process im_rgbd.depth and im_rgbd.color

rs.stop_capture()
