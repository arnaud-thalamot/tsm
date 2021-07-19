########################################################################################################################
#                                                                                                                      #
#                                   TSM attribute for TSCM Cookbook                                                    #
#                                                                                                                      #
#   Language            : Chef/Ruby                                                                                    #
#   Date                : 18.12.2017                                                                                   #
#   Date Last Update    : 31.01.2017                                                                                   #
#   Version             : 0.1                                                                                          #
#   Author              : Arnaud THALAMOT                                                                              #
#                                                                                                                      #
########################################################################################################################


describe 'antivirus_win::install' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
